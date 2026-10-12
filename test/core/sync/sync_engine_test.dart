import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';

import '../../helpers/fake_sync.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

const _serverSeries = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2b01';
final _today = LocalDate(2026, 10, 7);

Map<String, Object?> seriesJson(
  String id, {
  String title = 'Run',
  String startTime = '09:00',
  int duration = 1800,
}) => {
  'id': id,
  'lineage_id': id,
  'title': title,
  'notes': null,
  'category_id': null,
  'priority': 'medium',
  'planned_duration': duration,
  'start_date': '2026-10-07',
  'start_time': startTime,
  'time_zone': 'UTC',
  'recurrence': {
    'frequency': 'daily',
    'interval': 1,
    'weekdays': <int>[],
    'month_day': null,
    'until': null,
    'count': null,
  },
  'reminder_offsets': <int>[],
  'ended_on': null,
};

/// Offline-first sync end to end: real repositories, outbox, engine and
/// task handler on SQLite; only the server is fake.
void main() {
  late FixedClock clock;
  late TasksTestHarness h;
  late SyncTestRig rig;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 7));
    h = TasksTestHarness(clock: clock);
    rig = SyncTestRig(h);
  });

  tearDown(() => h.dispose());

  T ok<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw TestFailure('Expected Ok, got $failure'),
  };

  Future<Task> createTask({String title = 'Run'}) async => ok(
    await h.tasks.createTask(
      TaskDraft(
        details: TaskDetails(
          title: title,
          plannedDuration: const Duration(minutes: 30),
        ),
        schedule: TaskSchedule(
          startDate: _today,
          startTime: LocalTime(9, 0),
          timeZone: 'UTC',
          rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        ),
      ),
    ),
  );

  String occurrenceOn(String seriesId, LocalDate date) => occurrenceIdFor(
    seriesId: seriesId,
    originalLocalDate: DateTime(date.year, date.month, date.day),
  );

  Future<TaskOccurrence?> occurrence(String id) =>
      h.taskLocal.getOccurrence(id);

  group('push', () {
    test('an offline change stays local and queued, then syncs', () async {
      final task = await createTask();
      rig.server.pushError = networkError();

      expect(await rig.engine.sync(), const Failure.network());
      // Visible locally right away, op kept, no attempt counted.
      expect(ok(await h.tasks.getTask(task.id)).title, 'Run');
      final queued = await h.outboxRows();
      expect(queued.single.type, 'series.create');
      expect(queued.single.attempts, 0);

      rig.server.pushError = null;
      expect(await rig.engine.sync(), isNull);

      expect(await h.outboxRows(), isEmpty);
      expect(ok(await h.tasks.getTask(task.id)).version, 1);
      expect(rig.engine.state.lastSuccessAt, clock.current);
    });

    test('every op type reaches the server with stable ids', () async {
      final task = await createTask();
      final first = occurrenceOn(task.id, _today);
      final second = occurrenceOn(task.id, _today.addDays(1));
      final third = occurrenceOn(task.id, _today.addDays(2));
      ok(await h.tasks.applyAction(first, const CompleteOccurrence()));
      ok(
        await h.tasks.applyAction(
          second,
          const SkipOccurrence(SkipReason.forgot),
        ),
      );
      ok(
        await h.tasks.applyAction(
          third,
          PostponeOccurrence(toDate: _today.addDays(3)),
        ),
      );
      ok(await h.tasks.deleteTask(task.id));

      expect(await rig.engine.sync(), isNull);

      final ops = rig.server.pushed.single;
      expect(ops.map((o) => o.type), [
        'series.create',
        'occurrence.complete',
        'occurrence.skip',
        'occurrence.postpone',
        'series.delete',
      ]);
      expect(ops.map((o) => o.entityId), [
        task.id,
        first,
        second,
        third,
        task.id,
      ]);
      expect(ops.map((o) => o.opId).toSet(), hasLength(5));
    });

    test('a replayed batch is settled by duplicate results', () async {
      await createTask();
      rig.server.onPush = (ops) => [
        for (final op in ops)
          PushResult(opId: op.opId, status: PushStatus.duplicate, version: 4),
      ];

      expect(await rig.engine.sync(), isNull);
      expect(await h.outboxRows(), isEmpty);
    });

    test('a refused create is removed locally with its later ops', () async {
      final task = await createTask();
      ok(
        await h.tasks.updateTaskDetails(
          task.id,
          const TaskDetails(
            title: 'Run far',
            plannedDuration: Duration(minutes: 45),
          ),
        ),
      );
      ok(
        await h.tasks.applyAction(
          occurrenceOn(task.id, _today),
          const CompleteOccurrence(),
        ),
      );
      rig.server.onPush = (ops) => [
        PushResult(
          opId: ops.first.opId,
          status: PushStatus.rejected,
          code: 'VALIDATION_FAILED',
        ),
      ];

      expect(await rig.engine.sync(), isNull);

      expect(await h.outboxRows(), isEmpty);
      expect(await h.taskLocal.getTaskIncludingDeleted(task.id), isNull);
      expect(await occurrence(occurrenceOn(task.id, _today)), isNull);
      final issue = (await rig.issues()).single;
      expect(issue.code, 'VALIDATION_FAILED');
      expect(issue.opType, 'series.create');
      expect(issue.label, 'Run far');
      expect(issue.repairPending, isFalse);
    });

    test('a refused occurrence op takes the server state', () async {
      final task = await createTask();
      expect(await rig.engine.sync(), isNull);
      final id = occurrenceOn(task.id, _today);
      ok(await h.tasks.applyAction(id, const CompleteOccurrence()));
      // Another device skipped it first.
      rig.rest.occurrences[id] = {
        'id': id,
        'series_id': task.id,
        'original_date': '2026-10-07',
        'scheduled_date': '2026-10-07',
        'scheduled_start': '2026-10-07T09:00:00Z',
        'original_start': '2026-10-07T09:00:00Z',
        'planned_duration': 1800,
        'status': 'skipped',
        'skip_reason': 'no_time',
        'version': 3,
      };
      rig.server.onPush = (ops) => [
        PushResult(
          opId: ops.single.opId,
          status: PushStatus.rejected,
          code: 'ALREADY_RESOLVED',
        ),
      ];

      expect(await rig.engine.sync(), isNull);

      final local = await occurrence(id);
      expect(local?.status, OccurrenceStatus.skipped);
      expect(local?.skipReason, SkipReason.noTime);
      expect(local?.version, 3);
      final issue = (await rig.issues()).single;
      expect(issue.code, 'ALREADY_RESOLVED');
      expect(issue.label, 'Run');
      expect(issue.repairPending, isFalse);
    });

    test('a refused edit of an entity deleted elsewhere deletes it', () async {
      final task = await createTask();
      expect(await rig.engine.sync(), isNull);
      ok(
        await h.tasks.updateTaskDetails(
          task.id,
          const TaskDetails(
            title: 'Walk',
            plannedDuration: Duration(minutes: 30),
          ),
        ),
      );
      rig.server.onPush = (ops) => [
        PushResult(
          opId: ops.single.opId,
          status: PushStatus.rejected,
          code: 'ENTITY_DELETED',
        ),
      ];

      expect(await rig.engine.sync(), isNull);

      // The code says deleted: no server read needed.
      expect(await h.tasks.getTask(task.id), isA<Err<Task>>());
      expect(rig.rest.reads, 0);
      expect((await rig.issues()).single.label, 'Walk');
    });

    test('a repair that cannot reach the server is retried later', () async {
      final task = await createTask();
      expect(await rig.engine.sync(), isNull);
      ok(
        await h.tasks.updateTaskDetails(
          task.id,
          const TaskDetails(
            title: 'Walk',
            plannedDuration: Duration(minutes: 30),
          ),
        ),
      );
      rig.rest.offline = true;
      rig.server.onPush = (ops) => [
        PushResult(
          opId: ops.single.opId,
          status: PushStatus.rejected,
          code: 'STALE_VERSION',
        ),
      ];

      expect(await rig.engine.sync(), isNull);
      expect(ok(await h.tasks.getTask(task.id)).title, 'Walk');
      expect((await rig.issues()).single.repairPending, isTrue);

      // Dismissed meanwhile: hidden, but the repair still happens.
      await rig.issueStore.dismissAll();
      expect(await rig.issues(), isEmpty);

      rig.rest
        ..offline = false
        ..series[task.id] = {...seriesJson(task.id), 'version': 4};
      rig.server.onPush = null;
      expect(await rig.engine.sync(), isNull);

      final repaired = ok(await h.tasks.getTask(task.id));
      expect(repaired.title, 'Run');
      expect(repaired.version, 4);
      expect(await rig.issueStore.pendingRepairs(), isEmpty);
      expect(h.reporter.errors, isEmpty);
    });

    test('a bare 404 (proxy, missing route) never deletes data', () async {
      final task = await createTask();
      expect(await rig.engine.sync(), isNull);
      ok(
        await h.tasks.updateTaskDetails(
          task.id,
          const TaskDetails(
            title: 'Walk',
            plannedDuration: Duration(minutes: 30),
          ),
        ),
      );
      rig.rest.unrouted = true;
      rig.server.onPush = (ops) => [
        PushResult(
          opId: ops.single.opId,
          status: PushStatus.rejected,
          code: 'CONFLICT',
        ),
      ];

      expect(await rig.engine.sync(), isNull);
      expect(ok(await h.tasks.getTask(task.id)).title, 'Walk');
      expect((await rig.issues()).single.repairPending, isTrue);
    });

    test('a refused start removes the session it opened', () async {
      final task = await createTask();
      expect(await rig.engine.sync(), isNull);
      final id = occurrenceOn(task.id, _today);
      ok(await h.tasks.applyAction(id, const StartOccurrence()));
      expect(await h.taskLocal.openSessionExcept('other'), isNotNull);
      rig.rest.offline = true;
      rig.server.onPush = (ops) => [
        PushResult(
          opId: ops.single.opId,
          status: PushStatus.rejected,
          code: 'INVALID_TRANSITION',
        ),
      ];

      expect(await rig.engine.sync(), isNull);
      expect(await h.taskLocal.openSessionExcept('other'), isNull);
    });

    test('nothing runs while disabled (no prepared user)', () async {
      await createTask();
      rig.engine.enabled = false;
      expect(await rig.engine.sync(), const Failure.unauthenticated());
      expect(rig.server.pushed, isEmpty);
    });

    test('a refused op is isolated and given up; valid ops survive', () async {
      rig = SyncTestRig(h, maxAttempts: 2);
      final bad = await createTask(title: 'Bad');
      final good = await createTask(title: 'Good');
      rig.server.onPush = (ops) => ops.any((o) => o.entityId == bad.id)
          ? throw httpError(422)
          : [for (final op in ops) rig.server.applied(op)];

      // Batch refused: both counted once.
      expect(await rig.engine.sync(), isA<ValidationFailure>());
      // Alone and refused again: given up.
      expect(await rig.engine.sync(), isA<ValidationFailure>());
      expect(rig.server.pushed[1].map((o) => o.entityId), [bad.id]);
      // The good op goes alone (it was counted once), then succeeds.
      expect(await rig.engine.sync(), isNull);

      expect(await h.outboxRows(), isEmpty);
      expect(ok(await h.tasks.getTask(good.id)).version, 1);
      expect(await h.taskLocal.getTaskIncludingDeleted(bad.id), isNull);
      final issue = (await rig.issues()).single;
      expect(issue.code, 'SYNC_FAILED');
      expect(issue.entityId, bad.id);
    });

    test('outages and misconfiguration never give an op up', () async {
      rig = SyncTestRig(h, maxAttempts: 2);
      await createTask();
      rig.server.pushError = httpError(503);

      for (var i = 0; i < 5; i++) {
        expect(await rig.engine.sync(), isA<ServerFailure>());
      }
      rig.server.pushError = httpError(429);
      expect(await rig.engine.sync(), isA<ServerFailure>());
      // A wrong base URL or a forbidden account is not the op's fault.
      rig.server.pushError = httpError(404);
      expect(await rig.engine.sync(), isA<NotFoundFailure>());
      rig.server.pushError = httpError(403);
      expect(await rig.engine.sync(), isA<ForbiddenFailure>());

      final row = (await h.outboxRows()).single;
      expect(row.attempts, 0);
      expect(await rig.issues(), isEmpty);
    });
  });

  group('pull', () {
    test('applies server entities, stores the cursor, fills ahead', () async {
      final id = occurrenceOn(_serverSeries, _today);
      rig.server.pages.add(
        PullPage(
          changes: [
            SyncChange(
              entity: 'series',
              id: _serverSeries,
              version: 3,
              deleted: false,
              data: seriesJson(_serverSeries, title: 'Stretch'),
            ),
            SyncChange(
              entity: 'occurrence',
              id: id,
              version: 2,
              deleted: false,
              data: {
                'id': id,
                'series_id': _serverSeries,
                'original_date': '2026-10-07',
                'scheduled_date': '2026-10-07',
                'scheduled_start': '2026-10-07T09:00:00Z',
                'original_start': '2026-10-07T09:00:00Z',
                'planned_duration': 1800,
                'status': 'completed',
                'actual_duration': 1500,
                'resolved_at': '2026-10-07T09:30:00Z',
              },
            ),
          ],
          cursor: 40,
          hasMore: false,
        ),
      );

      expect(await rig.engine.sync(), isNull);

      expect(ok(await h.tasks.getTask(_serverSeries)).title, 'Stretch');
      expect((await occurrence(id))?.status, OccurrenceStatus.completed);
      expect(await rig.cursor.read(), 40);
      // Materialized after the pull, as on the server.
      expect(
        await occurrence(occurrenceOn(_serverSeries, _today.addDays(7))),
        isNotNull,
      );
      expect(await h.outboxRows(), isEmpty);
    });

    test('pages until has_more is false', () async {
      rig.server.pages.addAll([
        const PullPage(changes: [], cursor: 5, hasMore: true),
        const PullPage(changes: [], cursor: 9, hasMore: false),
      ]);

      expect(await rig.engine.sync(), isNull);
      expect(rig.server.pullCursors, [0, 5]);
      expect(await rig.cursor.read(), 9);
    });

    test('never overwrites an entity with local ops still queued', () async {
      final task = await createTask();
      // The server answers without settling the op: it stays queued.
      rig.server.onPush = (_) => [];
      rig.server.pages.add(
        PullPage(
          changes: [
            SyncChange(
              entity: 'series',
              id: task.id,
              version: 7,
              deleted: false,
              data: seriesJson(task.id, title: 'Server title'),
            ),
          ],
          cursor: 3,
          hasMore: false,
        ),
      );

      // Unprocessed ops stay queued, uncounted; the pull still runs.
      expect(await rig.engine.sync(), SyncEngine.notProcessed);

      expect(ok(await h.tasks.getTask(task.id)).title, 'Run');
      final row = (await h.outboxRows()).single;
      expect(row.attempts, 0);
      expect(await rig.cursor.read(), 3);
    });

    test('a delete from another device removes the task', () async {
      final task = await createTask();
      expect(await rig.engine.sync(), isNull);
      rig.server.pages.add(
        PullPage(
          changes: [
            SyncChange(
              entity: 'series',
              id: task.id,
              version: 2,
              deleted: true,
              data: const {},
            ),
          ],
          cursor: 8,
          hasMore: false,
        ),
      );

      expect(await rig.engine.sync(), isNull);

      expect(await h.tasks.getTask(task.id), isA<Err<Task>>());
      expect(await occurrence(occurrenceOn(task.id, _today)), isNull);
    });

    test('a schedule change re-plans untouched occurrences only', () async {
      final task = await createTask();
      final todayId = occurrenceOn(task.id, _today);
      ok(await h.tasks.applyAction(todayId, const CompleteOccurrence()));
      expect(await rig.engine.sync(), isNull);
      rig.server.pages.add(
        PullPage(
          changes: [
            SyncChange(
              entity: 'series',
              id: task.id,
              version: 5,
              deleted: false,
              data: seriesJson(task.id, startTime: '18:00', duration: 2700),
            ),
          ],
          cursor: 12,
          hasMore: false,
        ),
      );

      expect(await rig.engine.sync(), isNull);

      final done = await occurrence(todayId);
      expect(done?.status, OccurrenceStatus.completed);
      expect(done?.scheduledStart, DateTime.utc(2026, 10, 7, 9));
      final tomorrow = await occurrence(
        occurrenceOn(task.id, _today.addDays(1)),
      );
      expect(tomorrow?.scheduledStart, DateTime.utc(2026, 10, 8, 18));
      expect(tomorrow?.plannedDuration, const Duration(minutes: 45));
      expect(ok(await h.tasks.getTask(task.id)).version, 5);
    });

    test('an unreadable change is reported and skipped', () async {
      const other = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2b02';
      rig.server.pages.add(
        PullPage(
          changes: [
            const SyncChange(
              entity: 'series',
              id: _serverSeries,
              version: 1,
              deleted: false,
              data: {'id': _serverSeries},
            ),
            SyncChange(
              entity: 'series',
              id: other,
              version: 1,
              deleted: false,
              data: {...seriesJson(other), 'priority': 'urgent'},
            ),
            SyncChange(
              entity: 'series',
              id: _serverSeries,
              version: 2,
              deleted: false,
              data: seriesJson(_serverSeries, title: 'Good'),
            ),
          ],
          cursor: 50,
          hasMore: false,
        ),
      );

      expect(await rig.engine.sync(), isNull);

      expect(await rig.cursor.read(), 50);
      expect(ok(await h.tasks.getTask(_serverSeries)).title, 'Good');
      expect(await h.tasks.getTask(other), isA<Err<Task>>());
      expect(h.reporter.errors, hasLength(2));
      expect(h.reporter.errors, everyElement(isA<FormatException>()));
    });

    test('children listed before their parent are applied after it', () async {
      final id = occurrenceOn(_serverSeries, _today);
      rig.server.pages.add(
        PullPage(
          changes: [
            SyncChange(
              entity: 'occurrence',
              id: id,
              version: 1,
              deleted: false,
              data: {
                'id': id,
                'series_id': _serverSeries,
                'original_date': '2026-10-07',
                'scheduled_date': '2026-10-07',
                'planned_duration': 1800,
                'status': 'skipped',
                'skip_reason': 'forgot',
              },
            ),
            SyncChange(
              entity: 'series',
              id: _serverSeries,
              version: 1,
              deleted: false,
              data: seriesJson(_serverSeries),
            ),
          ],
          cursor: 4,
          hasMore: false,
        ),
      );

      expect(await rig.engine.sync(), isNull);
      expect((await occurrence(id))?.status, OccurrenceStatus.skipped);
    });

    test('a moved one-off keeps its single occurrence', () async {
      final task = ok(
        await h.tasks.createTask(
          TaskDraft(
            details: const TaskDetails(
              title: 'Dentist',
              plannedDuration: Duration(minutes: 60),
            ),
            schedule: TaskSchedule(
              startDate: _today.addDays(2),
              startTime: LocalTime(10, 0),
              timeZone: 'UTC',
            ),
          ),
        ),
      );
      expect(await rig.engine.sync(), isNull);
      final id = occurrenceOn(task.id, _today.addDays(2));
      final moved = {
        ...seriesJson(task.id, title: 'Dentist', startTime: '15:00'),
        'start_date': '2026-10-11',
        'planned_duration': 3600,
        'recurrence': {
          'frequency': 'none',
          'interval': 1,
          'weekdays': <int>[],
        },
      };
      rig.server.pages.add(
        PullPage(
          changes: [
            SyncChange(
              entity: 'series',
              id: task.id,
              version: 2,
              deleted: false,
              data: moved,
            ),
          ],
          cursor: 6,
          hasMore: false,
        ),
      );

      expect(await rig.engine.sync(), isNull);

      final occurrences = await h.taskLocal.occurrencesOf(task.id);
      expect(occurrences.map((o) => o.id), [id]);
      expect(occurrences.single.scheduledDate, LocalDate(2026, 10, 11));
      expect(
        occurrences.single.scheduledStart,
        DateTime.utc(2026, 10, 11, 15),
      );
      expect(occurrences.single.originalDate, _today.addDays(2));
    });

    test('unknown entities are skipped', () async {
      rig.server.pages.add(
        const PullPage(
          changes: [
            SyncChange(
              entity: 'insight',
              id: 'x',
              version: 1,
              deleted: false,
              data: {},
            ),
          ],
          cursor: 2,
          hasMore: false,
        ),
      );
      expect(await rig.engine.sync(), isNull);
      expect(await rig.cursor.read(), 2);
    });
  });

  group('runs', () {
    test('overlapping calls share a run that goes again', () async {
      await createTask(title: 'First');
      final gate = Completer<void>();
      rig.server.pushGate = gate;

      final first = rig.engine.sync();
      await pumpEventQueue();
      expect(rig.engine.state.running, isTrue);
      await createTask(title: 'Second');
      final second = rig.engine.sync();

      gate.complete();
      expect(await first, isNull);
      expect(await second, isNull);
      expect(rig.server.pushed, hasLength(2));
      expect(await h.outboxRows(), isEmpty);
      expect(rig.engine.state.running, isFalse);
    });

    test('state reports the failure until a run succeeds', () async {
      final states = <bool>[];
      final subscription = rig.engine.watch().listen(
        (s) => states.add(s.running),
      );
      addTearDown(subscription.cancel);
      rig.server.pullError = networkError();

      await rig.engine.sync();
      expect(rig.engine.state.lastFailure, const Failure.network());

      rig.server.pullError = null;
      await rig.engine.sync();
      expect(rig.engine.state.lastFailure, isNull);
      await pumpEventQueue();
      expect(states, [false, true, false, true, false]);
    });
  });
}
