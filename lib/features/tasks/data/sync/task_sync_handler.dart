import 'package:dio/dio.dart';
import 'package:productivity_planner/core/network/dio_failure_mapper.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/sync/sync_entity_handler.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/data/datasources/category_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_sync_remote_data_source.dart';
import 'package:productivity_planner/features/tasks/data/sync/pulled_entities.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';

/// Series, occurrences, work sessions and categories for the sync engine
/// (conflict rules: contract §4.3, docs/ARCHITECTURE.md §12f).
///
/// Server state overwrites local rows (the server has merged every
/// device's ops), except entities with local ops still queued. A schedule
/// change re-plans only the occurrences nobody touched, as a local edit
/// does.
final class TaskSyncHandler implements SyncEntityHandler {
  TaskSyncHandler({
    required TaskLocalDataSource tasks,
    required CategoryLocalDataSource categories,
    required TaskSyncRemoteDataSource remote,
    required TaskRepository repository,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _tasks = tasks,
       _categories = categories,
       _remote = remote,
       _repository = repository,
       _converter = converter,
       _clock = clock;

  final TaskLocalDataSource _tasks;
  final CategoryLocalDataSource _categories;
  final TaskSyncRemoteDataSource _remote;
  final TaskRepository _repository;
  final TimeZoneConverter _converter;
  final Clock _clock;

  static const series = 'series';
  static const occurrence = 'occurrence';
  static const workSession = 'work_session';
  static const category = 'category';

  /// Codes that mean the entity no longer exists on the server.
  static const goneCodes = {'ENTITY_DELETED', 'NOT_FOUND'};

  @override
  Set<String> get entities => const {
    series,
    occurrence,
    workSession,
    category,
  };

  @override
  int rankOf(String entity) => switch (entity) {
    occurrence => 1,
    workSession => 2,
    _ => 0,
  };

  @override
  bool ownsOp(String opType) =>
      _isSeries(opType) || _isOccurrence(opType) || _isCategory(opType);

  static bool _isSeries(String opType) => opType.startsWith('series.');
  static bool _isOccurrence(String opType) => opType.startsWith('occurrence.');
  static bool _isCategory(String opType) => opType.startsWith('category.');

  // Pull

  @override
  Future<void> applyChange(
    SyncChange change, {
    required Set<String> pending,
  }) async {
    switch (change.entity) {
      case series when !pending.contains(change.id):
        await _applySeries(change, pending);
      case occurrence when !pending.contains(change.id):
        await _applyOccurrence(change);
      case workSession:
        await _applySession(change, pending);
      case category when !pending.contains(change.id):
        await _applyCategory(change);
    }
  }

  Future<void> _applySeries(SyncChange change, Set<String> pending) async {
    final now = _clock.now();
    if (change.deleted) {
      await _deleteSeries(change.id, now);
      return;
    }
    final incoming = seriesFromJson(
      change.data,
      version: change.version,
      now: now,
    );
    final existing = await _tasks.getTaskIncludingDeleted(change.id);
    if (existing == null) {
      await _tasks.upsertTask(incoming);
      return;
    }
    final rescheduled =
        existing.schedule != incoming.schedule ||
        existing.endedOn != incoming.endedOn;
    final today = _today(incoming);
    var watermark = existing.materializedThrough;
    if (rescheduled && !existing.isRecurring && !incoming.isRecurring) {
      watermark = await _moveOneOff(incoming, watermark, pending);
    } else if (rescheduled) {
      await _dropUntouched(existing.id, from: today, pending: pending);
      // Re-planned from today by the next materialization.
      watermark = null;
    }
    if (existing.plannedDuration != incoming.plannedDuration) {
      await _tasks.updatePlannedDuration(
        existing.id,
        fromDate: today,
        duration: incoming.plannedDuration,
        now: now,
      );
    }
    await _tasks.upsertTask(
      incoming.copyWith(
        materializedThrough: watermark,
        createdAt: existing.createdAt,
      ),
    );
  }

  /// A moved one-off keeps its single occurrence (same id, same original
  /// date; contract §4.1), as the local edit does; the watermark covers
  /// the new date so planning never adds a second one. Returns the new
  /// watermark (null: nothing materialized yet, plan it normally).
  Future<LocalDate?> _moveOneOff(
    Task task,
    LocalDate? watermark,
    Set<String> pending,
  ) async {
    final schedule = task.schedule;
    final occurrences = await _tasks.occurrencesOf(task.id);
    if (occurrences.isEmpty) return null;
    final zone = schedule.timeZone;
    final time = _converter.isValidZone(zone) ? schedule.startTime : null;
    for (final o in occurrences) {
      if (o.status.isResolved || pending.contains(o.id)) continue;
      await _tasks.updateOccurrence(
        o.copyWith(
          scheduledDate: schedule.startDate,
          scheduledStart: time == null
              ? null
              : _converter.toUtc(schedule.startDate, time, zone),
          updatedAt: _clock.now(),
        ),
      );
    }
    return watermark == null
        ? schedule.startDate
        : maxDate(watermark, schedule.startDate);
  }

  Future<void> _applyOccurrence(SyncChange change) async {
    if (change.deleted) {
      await _tasks.deleteOccurrences([change.id]);
      return;
    }
    final incoming = occurrenceFromJson(
      change.data,
      version: change.version,
      now: _clock.now(),
    );
    // Parents come first (contract §4.3); a missing series was deleted
    // here, so the occurrence has nowhere to go.
    if (await _tasks.getTaskIncludingDeleted(incoming.seriesId) == null) {
      return;
    }
    final existing = await _tasks.getOccurrence(incoming.id);
    await _tasks.upsertOccurrence(
      existing == null
          ? incoming
          : incoming.copyWith(createdAt: existing.createdAt),
    );
  }

  Future<void> _applySession(SyncChange change, Set<String> pending) async {
    if (change.deleted) {
      await _tasks.deleteSessions([change.id]);
      return;
    }
    final session = sessionFromJson(change.data);
    // Sessions follow their occurrence: not while it has queued ops (the
    // server re-emits them once those apply), and not without it.
    if (pending.contains(session.occurrenceId)) return;
    if (await _tasks.getOccurrence(session.occurrenceId) == null) return;
    if (session.endedAt == null) {
      // One open session per occurrence: the server's.
      await _tasks.deleteOpenSessionsOf(
        session.occurrenceId,
        keepId: session.id,
      );
    }
    await _tasks.upsertSessions([session]);
  }

  Future<void> _applyCategory(SyncChange change) async {
    final now = _clock.now();
    if (change.deleted) {
      await _categories.markDeleted(change.id, now);
      return;
    }
    await _categories.upsert(
      categoryFromJson(change.data, version: change.version),
      now: now,
    );
  }

  Future<void> _deleteSeries(String id, DateTime now) async {
    await _tasks.markTaskDeleted(id, now);
    await _tasks.deleteOccurrencesOfSeries(id);
  }

  /// Removes occurrences nobody touched, from [from] on (a schedule
  /// change re-plans them). Occurrences with queued ops stay.
  Future<void> _dropUntouched(
    String seriesId, {
    required LocalDate from,
    required Set<String> pending,
  }) async {
    final occurrences = await _tasks.occurrencesOf(seriesId);
    await _tasks.deleteOccurrences([
      for (final o in occurrences)
        if (o.isPristine && o.scheduledDate >= from && !pending.contains(o.id))
          o.id,
    ]);
  }

  LocalDate _today(Task task) {
    final zone = task.schedule.timeZone;
    return _converter.localDate(
      _clock.now(),
      _converter.isValidZone(zone) ? zone : 'UTC',
    );
  }

  @override
  Future<void> afterPull() async {
    await _repository.materializeOccurrences();
  }

  // Push

  @override
  Future<void> applyVersion(SyncOp op, int version) async {
    if (_isSeries(op.type)) {
      await _tasks.setSeriesVersion(op.entityId, version);
    } else if (_isOccurrence(op.type)) {
      await _tasks.setOccurrenceVersion(op.entityId, version);
    } else if (_isCategory(op.type)) {
      await _categories.setVersion(op.entityId, version);
    }
  }

  @override
  Future<SyncRejection> onRejected(SyncOp op, String code) async {
    final label = await _label(op);
    final id = op.entityId;
    final now = _clock.now();
    final splitId = op.type == SyncOpType.seriesSplit.wire
        ? switch (op.payload['new_series']) {
            {'id': final String newId} => newId,
            _ => null,
          }
        : null;
    if (splitId != null) {
      // The successor series exists only here.
      await _tasks.deleteTaskRow(splitId);
    }

    if (op.type == SyncOpType.seriesCreate.wire) {
      // Never accepted: it exists nowhere else.
      await _tasks.deleteTaskRow(id);
      return SyncRejection(label: label, dropQueued: _targetsSeries({id}));
    }
    if (op.type == SyncOpType.categoryCreate.wire) {
      await _categories.deleteRow(id);
      return SyncRejection(label: label, dropQueued: _targets(id));
    }
    if (goneCodes.contains(code)) {
      if (_isSeries(op.type)) {
        await _deleteSeries(id, now);
        return SyncRejection(
          label: label,
          dropQueued: _targetsSeries({id, if (splitId case final s?) s}),
        );
      }
      if (_isOccurrence(op.type)) {
        await _tasks.deleteOccurrences([id]);
      } else if (_isCategory(op.type)) {
        await _categories.markDeleted(id, now);
      }
      return SyncRejection(label: label, dropQueued: _targets(id));
    }
    if (op.type == SyncOpType.occurrenceStart.wire ||
        op.type == SyncOpType.occurrenceResume.wire) {
      // The session it opened exists only here.
      if (op.payload['session_id'] case final String sessionId) {
        await _tasks.deleteSessions([sessionId]);
      }
    }
    return SyncRejection(
      label: label,
      needsRepair: true,
      dropQueued: splitId == null ? null : _targetsSeries({splitId}),
    );
  }

  static bool Function(SyncOp) _targets(String id) =>
      (op) => op.entityId == id;

  /// Ops on these series, including occurrence ops (their payload names
  /// the series).
  static bool Function(SyncOp) _targetsSeries(Set<String> ids) =>
      (op) =>
          ids.contains(op.entityId) || ids.contains(op.payload['series_id']);

  Future<String?> _label(SyncOp op) async {
    if (_isSeries(op.type)) {
      return (await _tasks.getTaskIncludingDeleted(op.entityId))?.title;
    }
    if (_isOccurrence(op.type)) {
      final found = await _tasks.getOccurrence(op.entityId);
      if (found == null) return null;
      return (await _tasks.getTaskIncludingDeleted(found.seriesId))?.title;
    }
    if (_isCategory(op.type)) {
      return (await _categories.getCategory(op.entityId))?.name;
    }
    return null;
  }

  @override
  Future<bool> repair(
    String opType,
    String entityId, {
    required Set<String> pending,
  }) async {
    // Its queued ops will change it on the server, and the pull after
    // that push brings the merged state.
    if (pending.contains(entityId)) return true;
    if (_isSeries(opType)) return _repairSeries(entityId, pending);
    if (_isOccurrence(opType)) return _repairOccurrence(entityId);
    if (_isCategory(opType)) return _repairCategory(entityId);
    return true;
  }

  Future<bool> _repairSeries(String id, Set<String> pending) async {
    final Map<String, Object?> data;
    try {
      data = await _remote.getSeries(id);
    } on DioException catch (error) {
      if (!_isNotFound(error)) return false;
      await _tasks.transaction(() => _deleteSeries(id, _clock.now()));
      return true;
    }
    await _tasks.transaction(
      () => _applySeries(_change(series, id, data), pending),
    );
    return true;
  }

  Future<bool> _repairOccurrence(String id) async {
    final Map<String, Object?> data;
    try {
      data = await _remote.getOccurrence(id);
    } on DioException catch (error) {
      if (!_isNotFound(error)) return false;
      await _tasks.deleteOccurrences([id]);
      return true;
    }
    await _tasks.transaction(
      () => _applyOccurrence(_change(occurrence, id, data)),
    );
    return true;
  }

  Future<bool> _repairCategory(String id) async {
    final List<Map<String, Object?>> all;
    try {
      all = await _remote.getCategories();
    } on DioException {
      return false;
    }
    final data = all.where((c) => c['id'] == id).firstOrNull;
    if (data == null) {
      // The list holds every active category: this one is deleted.
      await _categories.markDeleted(id, _clock.now());
    } else {
      await _applyCategory(_change(category, id, data));
    }
    return true;
  }

  /// Only the server's own "not found" means deleted; a 404 from a proxy
  /// or a missing route must never delete data.
  static bool _isNotFound(DioException error) {
    final response = error.response;
    return response?.statusCode == 404 &&
        parseProblemDetails(response?.data)?.code == 'NOT_FOUND';
  }

  static SyncChange _change(
    String entity,
    String id,
    Map<String, Object?> data,
  ) => SyncChange(
    entity: entity,
    id: id,
    version: switch (data['version']) {
      final int version => version,
      _ => 0,
    },
    deleted: false,
    data: data,
  );
}
