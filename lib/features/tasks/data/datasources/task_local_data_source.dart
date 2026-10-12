import 'package:drift/drift.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/data/models/task_mappers.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/occurrence_event.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

/// Drift queries for series, occurrences, sessions and events. Speaks in
/// entities; transactions and sync ops are the repository's job.
///
/// Errors propagate as exceptions; the repository maps them to failures.
final class TaskLocalDataSource {
  const TaskLocalDataSource(this._db);

  final AppDatabase _db;

  /// Runs [action] in one transaction. Nested calls join the outer one.
  Future<T> transaction<T>(Future<T> Function() action) =>
      _db.transaction(action);

  // Reads

  Stream<List<AgendaItem>> watchAgenda({
    required LocalDate from,
    required LocalDate to,
  }) => _agendaQuery(
    _db.taskOccurrences.scheduledDate.isBetweenValues(
      from.toString(),
      to.toString(),
    ),
  ).watch().map(_groupAgenda);

  Stream<AgendaItem?> watchAgendaItem(String occurrenceId) =>
      _agendaQuery(_db.taskOccurrences.id.equals(occurrenceId)).watch().map(
        (rows) {
          final items = _groupAgenda(rows);
          return items.isEmpty ? null : items.first;
        },
      );

  Stream<List<AgendaItem>> watchInProgress() => _agendaQuery(
    _db.taskOccurrences.status.equals(
      occurrenceStatusWire.wire(OccurrenceStatus.inProgress),
    ),
  ).watch().map(_groupAgenda);

  Stream<List<AgendaItem>> watchLineage(
    String lineageId, {
    required LocalDate from,
    required LocalDate to,
  }) => _agendaQuery(
    _db.taskSeries.lineageId.equals(lineageId) &
        _db.taskOccurrences.scheduledDate.isBetweenValues(
          from.toString(),
          to.toString(),
        ),
  ).watch().map(_groupAgenda);

  /// Occurrences joined with their (non-deleted) series, category and every
  /// work session. Drift re-runs it when any of the four tables changes.
  JoinedSelectStatement<HasResultSet, dynamic> _agendaQuery(
    Expression<bool> filter,
  ) {
    final o = _db.taskOccurrences;
    final s = _db.taskSeries;
    final c = _db.categories;
    final w = _db.workSessions;
    return _db.select(o).join([
        innerJoin(s, s.id.equalsExp(o.seriesId)),
        leftOuterJoin(c, c.id.equalsExp(s.categoryId) & c.deletedAt.isNull()),
        leftOuterJoin(w, w.occurrenceId.equalsExp(o.id)),
      ])
      ..where(filter & s.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(o.id), OrderingTerm.asc(w.startedAt)]);
  }

  List<AgendaItem> _groupAgenda(List<TypedResult> rows) {
    final items = <String, AgendaItem>{};
    final sessions = <String, List<WorkSession>>{};
    for (final row in rows) {
      final occurrenceRow = row.readTable(_db.taskOccurrences);
      final id = occurrenceRow.id;
      items.putIfAbsent(id, () {
        final category = row.readTableOrNull(_db.categories);
        return AgendaItem(
          occurrence: occurrenceFromRow(occurrenceRow),
          task: taskFromRow(row.readTable(_db.taskSeries)),
          category: category == null ? null : categoryFromRow(category),
        );
      });
      final session = row.readTableOrNull(_db.workSessions);
      if (session != null) {
        (sessions[id] ??= []).add(sessionFromRow(session));
      }
    }
    return [
      for (final entry in items.entries)
        entry.value.copyWith(sessions: sessions[entry.key] ?? const []),
    ];
  }

  Future<Task?> getTask(String id) async {
    final row =
        await (_db.select(_db.taskSeries)
              ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
            .getSingleOrNull();
    return row == null ? null : taskFromRow(row);
  }

  /// Series that may still produce occurrences.
  Future<List<Task>> activeTasks() async {
    final rows = await (_db.select(
      _db.taskSeries,
    )..where((t) => t.deletedAt.isNull())).get();
    return rows.map(taskFromRow).toList();
  }

  Future<TaskOccurrence?> getOccurrence(String id) async {
    final row = await (_db.select(
      _db.taskOccurrences,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : occurrenceFromRow(row);
  }

  /// A series' occurrences, optionally only those whose original date is on
  /// or after [fromOriginalDate].
  Future<List<TaskOccurrence>> occurrencesOf(
    String seriesId, {
    LocalDate? fromOriginalDate,
  }) async {
    final query = _db.select(_db.taskOccurrences)
      ..where((t) {
        final ofSeries = t.seriesId.equals(seriesId);
        return fromOriginalDate == null
            ? ofSeries
            : ofSeries &
                  t.originalDate.isBiggerOrEqualValue(
                    fromOriginalDate.toString(),
                  );
      });
    return (await query.get()).map(occurrenceFromRow).toList();
  }

  Future<List<WorkSession>> sessionsOf(String occurrenceId) async {
    final rows =
        await (_db.select(_db.workSessions)
              ..where((t) => t.occurrenceId.equals(occurrenceId))
              ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
            .get();
    return rows.map(sessionFromRow).toList();
  }

  /// The running session of any occurrence other than [occurrenceId].
  Future<WorkSession?> openSessionExcept(String occurrenceId) async {
    final rows =
        await (_db.select(_db.workSessions)
              ..where(
                (t) =>
                    t.endedAt.isNull() & t.occurrenceId.equals(occurrenceId).not(),
              )
              ..limit(1))
            .get();
    return rows.isEmpty ? null : sessionFromRow(rows.first);
  }

  Future<List<OccurrenceEvent>> eventsOf(String occurrenceId) async {
    final rows =
        await (_db.select(_db.occurrenceEvents)
              ..where((t) => t.occurrenceId.equals(occurrenceId))
              ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
            .get();
    return rows.map(eventFromRow).toList();
  }

  // Writes

  /// Inserts or updates every column except `deleted_at`.
  Future<void> upsertTask(Task task) =>
      _db.into(_db.taskSeries).insertOnConflictUpdate(taskToCompanion(task));

  Future<void> markTaskDeleted(String id, DateTime now) =>
      (_db.update(_db.taskSeries)..where((t) => t.id.equals(id))).write(
        TaskSeriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );

  /// Inserts the occurrences that do not exist yet (by id) and returns how
  /// many were inserted. Existing rows, possibly changed by the user or by
  /// sync, are never overwritten.
  Future<int> insertMissingOccurrences(List<TaskOccurrence> occurrences) async {
    if (occurrences.isEmpty) return 0;
    final ids = occurrences.map((o) => o.id).toList();
    final existing = await (_db.selectOnly(_db.taskOccurrences)
          ..addColumns([_db.taskOccurrences.id])
          ..where(_db.taskOccurrences.id.isIn(ids)))
        .map((row) => row.read(_db.taskOccurrences.id))
        .get();
    final known = existing.whereType<String>().toSet();
    final missing = occurrences.where((o) => !known.contains(o.id)).toList();
    await _db.batch((batch) {
      batch.insertAll(
        _db.taskOccurrences,
        missing.map(occurrenceToCompanion),
        mode: InsertMode.insertOrIgnore,
      );
    });
    return missing.length;
  }

  /// Updates an existing occurrence in place (never delete + insert, which
  /// would cascade to its sessions and events).
  Future<void> updateOccurrence(TaskOccurrence occurrence) =>
      (_db.update(_db.taskOccurrences)
            ..where((t) => t.id.equals(occurrence.id)))
          .write(occurrenceToCompanion(occurrence));

  Future<void> deleteOccurrences(Iterable<String> ids) {
    final list = ids.toList();
    if (list.isEmpty) return Future.value();
    return (_db.delete(_db.taskOccurrences)..where((t) => t.id.isIn(list)))
        .go();
  }

  Future<void> deleteOccurrencesOfSeries(String seriesId) => (_db.delete(
    _db.taskOccurrences,
  )..where((t) => t.seriesId.equals(seriesId))).go();

  /// Applies a new planned duration to the series' occurrences dated
  /// [fromDate] or later that have not started.
  Future<void> updatePlannedDuration(
    String seriesId, {
    required LocalDate fromDate,
    required Duration duration,
    required DateTime now,
  }) =>
      (_db.update(_db.taskOccurrences)..where(
            (t) =>
                t.seriesId.equals(seriesId) &
                t.scheduledDate.isBiggerOrEqualValue(fromDate.toString()) &
                t.status.equals(
                  occurrenceStatusWire.wire(OccurrenceStatus.scheduled),
                ),
          ))
          .write(
            TaskOccurrencesCompanion(
              plannedDurationSeconds: Value(duration.inSeconds),
              updatedAt: Value(now),
            ),
          );

  Future<void> upsertSessions(Iterable<WorkSession> sessions) async {
    for (final session in sessions) {
      await _db
          .into(_db.workSessions)
          .insertOnConflictUpdate(sessionToCompanion(session));
    }
  }

  // Sync (Phase 11): server state applied locally.

  /// Inserts or updates in place (an upsert, not a replace, so sessions and
  /// events stay).
  Future<void> upsertOccurrence(TaskOccurrence occurrence) => _db
      .into(_db.taskOccurrences)
      .insertOnConflictUpdate(occurrenceToCompanion(occurrence));

  /// Including soft-deleted series.
  Future<Task?> getTaskIncludingDeleted(String id) async {
    final row = await (_db.select(
      _db.taskSeries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : taskFromRow(row);
  }

  /// Removes the series row; its occurrences, sessions and events go with
  /// it (cascade). For a series the server never accepted.
  Future<void> deleteTaskRow(String id) =>
      (_db.delete(_db.taskSeries)..where((t) => t.id.equals(id))).go();

  Future<void> deleteSessions(Iterable<String> ids) {
    final list = ids.toList();
    if (list.isEmpty) return Future.value();
    return (_db.delete(_db.workSessions)..where((t) => t.id.isIn(list))).go();
  }

  /// Removes the occurrence's open sessions other than [keepId]: at most
  /// one session per occurrence may be open, and the server's wins.
  Future<void> deleteOpenSessionsOf(String occurrenceId, {String? keepId}) =>
      (_db.delete(_db.workSessions)..where(
            (t) =>
                t.occurrenceId.equals(occurrenceId) &
                t.endedAt.isNull() &
                (keepId == null
                    ? const Constant(true)
                    : t.id.equals(keepId).not()),
          ))
          .go();

  /// Raises the row's server version (never lowers it).
  Future<void> setSeriesVersion(String id, int version) =>
      (_db.update(_db.taskSeries)..where(
            (t) => t.id.equals(id) & t.version.isSmallerThanValue(version),
          ))
          .write(TaskSeriesCompanion(version: Value(version)));

  Future<void> setOccurrenceVersion(String id, int version) =>
      (_db.update(_db.taskOccurrences)..where(
            (t) => t.id.equals(id) & t.version.isSmallerThanValue(version),
          ))
          .write(TaskOccurrencesCompanion(version: Value(version)));

  Future<void> insertEvents(Iterable<OccurrenceEvent> events) async {
    final list = events.toList();
    if (list.isEmpty) return;
    await _db.batch(
      (batch) =>
          batch.insertAll(_db.occurrenceEvents, list.map(eventToCompanion)),
    );
  }
}
