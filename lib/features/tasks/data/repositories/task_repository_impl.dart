import 'dart:async';

import 'package:productivity_planner/core/database/local_guard.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/models/sync_payload_dtos.dart';
import 'package:productivity_planner/features/tasks/data/models/task_mappers.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

/// Offline-first [TaskRepository]: every write is one local transaction
/// containing the change and its outbox op(s). The sync engine (Phase 11)
/// pushes the outbox; nothing here touches the network.
final class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskLocalDataSource local,
    required OutboxWriter outbox,
    required OccurrencePlanner planner,
    required OccurrenceLifecycle lifecycle,
    required TimeZoneConverter converter,
    required IdGenerator ids,
    required Clock clock,
    required ErrorReporter reporter,
  }) : _local = local,
       _outbox = outbox,
       _planner = planner,
       _lifecycle = lifecycle,
       _converter = converter,
       _ids = ids,
       _clock = clock,
       _reporter = reporter;

  final TaskLocalDataSource _local;
  final OutboxWriter _outbox;
  final OccurrencePlanner _planner;
  final OccurrenceLifecycle _lifecycle;
  final TimeZoneConverter _converter;
  final IdGenerator _ids;
  final Clock _clock;
  final ErrorReporter _reporter;

  static const _notFound = Failure.notFound(entity: 'task');

  // Reads

  @override
  Stream<Result<List<AgendaItem>>> watchAgenda({
    required LocalDate from,
    required LocalDate to,
  }) => guardLocalStream(
    _reporter,
    'watchAgenda',
    _local.watchAgenda(from: from, to: to),
  );

  @override
  Stream<Result<AgendaItem?>> watchAgendaItem(String occurrenceId) =>
      guardLocalStream(
        _reporter,
        'watchAgendaItem',
        _local.watchAgendaItem(occurrenceId),
      );

  @override
  Stream<Result<List<AgendaItem>>> watchInProgress() => guardLocalStream(
    _reporter,
    'watchInProgress',
    _local.watchInProgress(),
  );

  @override
  Stream<Result<List<AgendaItem>>> watchLineage(
    String lineageId, {
    required LocalDate from,
    required LocalDate to,
  }) => guardLocalStream(
    _reporter,
    'watchLineage',
    _local.watchLineage(lineageId, from: from, to: to),
  );

  @override
  Future<Result<Task>> getTask(String taskId) =>
      guardLocal(_reporter, 'getTask', () async {
        final task = await _local.getTask(taskId);
        return task == null ? const Err(_notFound) : Ok(task);
      });

  @override
  Future<Result<List<Task>>> listTasks() => guardLocal(
    _reporter,
    'listTasks',
    () async => Ok(await _local.activeTasks()),
  );

  // Series writes

  @override
  Future<Result<Task>> createTask(TaskDraft draft) => guardLocal(
    _reporter,
    'createTask',
    () => _local.transaction(() async {
      final now = _clock.now();
      final id = _ids.newId();
      final details = draft.details;
      final task = Task(
        id: id,
        lineageId: id,
        title: details.title,
        notes: details.notes,
        categoryId: details.categoryId,
        priority: details.priority,
        plannedDuration: details.plannedDuration,
        schedule: draft.schedule,
        reminderOffsets: details.reminderOffsets,
        createdAt: now,
        updatedAt: now,
      );
      final saved = await _saveAndMaterialize(task, now);
      await _outbox.enqueue(
        type: SyncOpType.seriesCreate,
        entityId: saved.id,
        payload: SeriesDto.fromTask(saved).toJson(),
        occurredAt: now,
      );
      return Ok(saved);
    }),
  );

  @override
  Future<Result<Task>> updateTaskDetails(String taskId, TaskDetails details) =>
      guardLocal(
        _reporter,
        'updateTaskDetails',
        () => _local.transaction(() async {
          final task = await _local.getTask(taskId);
          if (task == null) return const Err(_notFound);
          final now = _clock.now();
          final updated = task.copyWith(
            title: details.title,
            notes: details.notes,
            categoryId: details.categoryId,
            priority: details.priority,
            plannedDuration: details.plannedDuration,
            reminderOffsets: details.reminderOffsets,
            updatedAt: now,
          );
          await _local.upsertTask(updated);
          if (updated.plannedDuration != task.plannedDuration) {
            await _local.updatePlannedDuration(
              task.id,
              fromDate: _today(task, now),
              duration: updated.plannedDuration,
              now: now,
            );
          }
          await _enqueueSeriesUpdate(updated, baseVersion: task.version, now);
          return Ok(updated);
        }),
      );

  @override
  Future<Result<Task>> rescheduleFrom(
    String taskId, {
    required LocalDate fromDate,
    required TaskSchedule schedule,
  }) => guardLocal(
    _reporter,
    'rescheduleFrom',
    () => _local.transaction(() async {
      final task = await _local.getTask(taskId);
      if (task == null) return const Err(_notFound);
      final now = _clock.now();
      final newSchedule = schedule.copyWith(startDate: fromDate);

      if (!task.isRecurring && !newSchedule.rule.isRecurring) {
        return await _moveOneOff(task, newSchedule, now);
      }

      // A one-off task has no history to split off; nor does a series
      // changed from its first day on.
      final inPlace = !task.isRecurring || fromDate <= task.schedule.startDate;
      await _deletePristine(
        task.id,
        fromOriginalDate: inPlace
            ? minDate(task.schedule.startDate, fromDate)
            : fromDate,
      );

      if (inPlace) {
        final edited = await _saveAndMaterialize(
          task.copyWith(
            schedule: newSchedule,
            materializedThrough: null,
            updatedAt: now,
          ),
          now,
        );
        await _enqueueSeriesUpdate(edited, baseVersion: task.version, now);
        return Ok(edited);
      }

      // Split: history stays on the old series, the future on a new one.
      final dayBefore = fromDate.addDays(-1);
      final previousEnd = task.endedOn;
      final ended = task.copyWith(
        endedOn: previousEnd == null
            ? dayBefore
            : minDate(previousEnd, dayBefore),
        updatedAt: now,
      );
      await _local.upsertTask(ended);

      // Occurrences of the old series that now sit on or after the split
      // date (touched ones, including postponed into that range) stay with
      // it; the new series must not add a second one on those days.
      final kept = (await _local.occurrencesOf(
        task.id,
      )).where((o) => o.scheduledDate >= fromDate);
      final successor = await _saveAndMaterialize(
        Task(
          id: _ids.newId(),
          lineageId: task.lineageId,
          title: task.title,
          notes: task.notes,
          categoryId: task.categoryId,
          priority: task.priority,
          plannedDuration: task.plannedDuration,
          schedule: newSchedule,
          reminderOffsets: task.reminderOffsets,
          createdAt: now,
          updatedAt: now,
        ),
        now,
        skipDates: {for (final o in kept) o.scheduledDate},
      );
      await _outbox.enqueue(
        type: SyncOpType.seriesSplit,
        entityId: task.id,
        baseVersion: task.version,
        payload: SeriesSplitDto(
          sourceSeriesId: task.id,
          splitDate: fromDate.toString(),
          newSeries: SeriesDto.fromTask(successor),
        ).toJson(),
        occurredAt: now,
      );
      return Ok(successor);
    }),
  );

  @override
  Future<Result<Unit>> endTask(String taskId, {required LocalDate lastDate}) =>
      guardLocal(
        _reporter,
        'endTask',
        () => _local.transaction(() async {
          final task = await _local.getTask(taskId);
          if (task == null) return const Err(_notFound);
          final now = _clock.now();
          final previousEnd = task.endedOn;
          final ended = task.copyWith(
            endedOn: previousEnd == null
                ? lastDate
                : minDate(previousEnd, lastDate),
            updatedAt: now,
          );
          await _deletePristine(task.id, fromOriginalDate: lastDate.addDays(1));
          await _local.upsertTask(ended);
          await _enqueueSeriesUpdate(ended, baseVersion: task.version, now);
          return const Ok(unit);
        }),
      );

  @override
  Future<Result<Unit>> deleteTask(String taskId) => guardLocal(
    _reporter,
    'deleteTask',
    () => _local.transaction(() async {
      final task = await _local.getTask(taskId);
      if (task == null) return const Err(_notFound);
      final now = _clock.now();
      await _local.markTaskDeleted(task.id, now);
      await _local.deleteOccurrencesOfSeries(task.id);
      await _outbox.enqueue(
        type: SyncOpType.seriesDelete,
        entityId: task.id,
        baseVersion: task.version,
        payload: const {},
        occurredAt: now,
      );
      return const Ok(unit);
    }),
  );

  // Occurrences

  @override
  Future<Result<LifecycleOutcome>> applyAction(
    String occurrenceId,
    OccurrenceAction action,
  ) => guardLocal(
    _reporter,
    'applyAction',
    () => _local.transaction(() async {
      final occurrence = await _local.getOccurrence(occurrenceId);
      if (occurrence == null) {
        return const Err(Failure.notFound(entity: 'occurrence'));
      }
      final task = await _local.getTask(occurrence.seriesId);
      if (task == null) return const Err(_notFound);

      final now = _clock.now();
      final result = _lifecycle.apply(
        occurrence: occurrence,
        action: action,
        sessions: await _local.sessionsOf(occurrence.id),
        otherOpenSession: action is StartOccurrence
            ? await _local.openSessionExcept(occurrence.id)
            : null,
        timeZone: task.schedule.timeZone,
        now: now,
      );
      // A rejected action has written nothing, so returning commits an
      // empty transaction.
      if (result case Ok(value: final outcome)) {
        await _persist(outcome, previous: occurrence, now: now);
      }
      return result;
    }),
  );

  @override
  Future<Result<int>> materializeOccurrences() => guardLocal(
    _reporter,
    'materializeOccurrences',
    () => _local.transaction(() async {
      final now = _clock.now();
      var created = 0;
      for (final task in await _local.activeTasks()) {
        if (!_converter.isValidZone(task.schedule.timeZone)) {
          // Synced from a device with newer tz data; skip rather than fail
          // every other series.
          unawaited(
            _reporter.report(
              ArgumentError.value(task.schedule.timeZone, 'timeZone'),
              StackTrace.current,
              context: {'series_id': task.id},
            ),
          );
          continue;
        }
        final plan = _planner.plan(task, today: _today(task, now), now: now);
        if (plan == null) continue;
        created += await _local.insertMissingOccurrences(plan.occurrences);
        // Bookkeeping only: not a user change, so no outbox op and no
        // updatedAt bump.
        await _local.upsertTask(
          task.copyWith(materializedThrough: plan.through),
        );
      }
      return Ok(created);
    }),
  );

  // Helpers

  LocalDate _today(Task task, DateTime now) =>
      _converter.localDate(now, task.schedule.timeZone);

  /// Saves [task] with its occurrences up to the horizon (except on
  /// [skipDates]); returns it with the new watermark.
  Future<Task> _saveAndMaterialize(
    Task task,
    DateTime now, {
    Set<LocalDate> skipDates = const {},
  }) async {
    final plan = _planner.plan(task, today: _today(task, now), now: now);
    final saved = plan == null
        ? task
        : task.copyWith(materializedThrough: plan.through);
    await _local.upsertTask(saved);
    if (plan != null) {
      await _local.insertMissingOccurrences([
        for (final o in plan.occurrences)
          if (!skipDates.contains(o.originalDate)) o,
      ]);
    }
    return saved;
  }

  /// A one-off task keeps its single occurrence (same id, notes and
  /// history) and moves it to the new slot. A finished one cannot move.
  Future<Result<Task>> _moveOneOff(
    Task task,
    TaskSchedule schedule,
    DateTime now,
  ) async {
    final occurrences = await _local.occurrencesOf(task.id);
    if (occurrences.any((o) => o.status.isResolved)) {
      return const Err(
        Failure.validation(
          fieldErrors: {TaskFields.startDate: TaskRuleCodes.alreadyResolved},
        ),
      );
    }
    final edited = task.copyWith(schedule: schedule, updatedAt: now);
    final existing = occurrences.firstOrNull;
    final Task saved;
    if (existing == null) {
      // Not materialized yet (beyond the horizon): plan it normally.
      saved = await _saveAndMaterialize(
        edited.copyWith(materializedThrough: null),
        now,
      );
    } else {
      final time = schedule.startTime;
      await _local.updateOccurrence(
        existing.copyWith(
          scheduledDate: schedule.startDate,
          scheduledStart: time == null
              ? null
              : _converter.toUtc(schedule.startDate, time, schedule.timeZone),
          updatedAt: now,
        ),
      );
      // The watermark covers the new date, so planning never adds a second
      // occurrence for it.
      final watermark = task.materializedThrough;
      saved = edited.copyWith(
        materializedThrough: watermark == null
            ? schedule.startDate
            : maxDate(watermark, schedule.startDate),
      );
      await _local.upsertTask(saved);
    }
    await _enqueueSeriesUpdate(saved, baseVersion: task.version, now);
    return Ok(saved);
  }

  /// Removes occurrences the user never touched, from [fromOriginalDate]
  /// on. Touched ones (started, resolved, postponed, annotated) are history
  /// and stay.
  Future<void> _deletePristine(
    String seriesId, {
    required LocalDate fromOriginalDate,
  }) async {
    final occurrences = await _local.occurrencesOf(
      seriesId,
      fromOriginalDate: fromOriginalDate,
    );
    await _local.deleteOccurrences(
      occurrences.where((o) => o.isPristine).map((o) => o.id),
    );
  }

  Future<void> _enqueueSeriesUpdate(
    Task task,
    DateTime now, {
    required int baseVersion,
  }) => _outbox.enqueue(
    type: SyncOpType.seriesUpdate,
    entityId: task.id,
    baseVersion: baseVersion,
    payload: SeriesDto.fromTask(task).toJson(),
    occurredAt: now,
  );

  Future<void> _persist(
    LifecycleOutcome outcome, {
    required TaskOccurrence previous,
    required DateTime now,
  }) async {
    final occurrence = outcome.occurrence;
    await _local.updateOccurrence(occurrence);
    await _local.upsertSessions(outcome.sessions);
    await _local.insertEvents(outcome.events);

    final ownSession = outcome.sessions
        .where((s) => s.occurrenceId == occurrence.id)
        .firstOrNull;
    await _outbox.enqueue(
      type: _opType(outcome.transition),
      entityId: occurrence.id,
      baseVersion: previous.version,
      payload: switch (outcome.transition) {
        OccurrenceTransition.noteUpdated => OccurrenceNoteDto(
          seriesId: occurrence.seriesId,
          originalDate: occurrence.originalDate.toString(),
          note: occurrence.note,
        ).toJson(),
        _ => OccurrenceActionDto.of(
          occurrence,
          sessionId: ownSession?.id,
          actualDuration:
              outcome.transition == OccurrenceTransition.completed
              ? occurrence.actualDuration?.inSeconds
              : null,
          reason: outcome.transition == OccurrenceTransition.skipped
              ? skipReasonWire.wireOrNull(occurrence.skipReason)
              : null,
          toDate: outcome.transition == OccurrenceTransition.postponed
              ? occurrence.scheduledDate.toString()
              : null,
          toStart: outcome.transition == OccurrenceTransition.postponed
              ? occurrence.scheduledStart?.toIso8601String()
              : null,
        ).toJson(),
      },
      occurredAt: now,
    );

    final autoPaused = outcome.autoPausedSession;
    if (autoPaused == null) return;
    final other = await _local.getOccurrence(autoPaused.occurrenceId);
    if (other == null) return;
    await _local.updateOccurrence(other.copyWith(updatedAt: now));
    await _outbox.enqueue(
      type: SyncOpType.occurrencePause,
      entityId: other.id,
      baseVersion: other.version,
      payload: OccurrenceActionDto.of(other, sessionId: autoPaused.id).toJson(),
      occurredAt: now,
    );
  }

  static SyncOpType _opType(OccurrenceTransition transition) =>
      switch (transition) {
        OccurrenceTransition.started => SyncOpType.occurrenceStart,
        OccurrenceTransition.resumed => SyncOpType.occurrenceResume,
        OccurrenceTransition.paused => SyncOpType.occurrencePause,
        OccurrenceTransition.completed => SyncOpType.occurrenceComplete,
        OccurrenceTransition.skipped => SyncOpType.occurrenceSkip,
        OccurrenceTransition.postponed => SyncOpType.occurrencePostpone,
        OccurrenceTransition.cancelled => SyncOpType.occurrenceCancel,
        OccurrenceTransition.reopened => SyncOpType.occurrenceReopen,
        OccurrenceTransition.noteUpdated => SyncOpType.occurrenceUpdate,
      };
}
