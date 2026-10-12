import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/session/sync_scheduler.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

import '../../helpers/fake_sync.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

/// Real timers with short durations; the engine and database are real, the
/// server, network state and session are fakes.
void main() {
  late TasksTestHarness h;
  late SyncTestRig rig;
  late FakeConnectivity connectivity;
  late StreamController<String?> users;
  late SyncScheduler scheduler;

  const debounce = Duration(milliseconds: 30);
  const interval = Duration(milliseconds: 400);
  const minBackoff = Duration(milliseconds: 40);

  setUp(() {
    h = TasksTestHarness(clock: FixedClock(DateTime.utc(2026, 10, 7, 7)));
    rig = SyncTestRig(h);
    connectivity = FakeConnectivity();
    users = StreamController<String?>.broadcast(sync: true);
    scheduler = SyncScheduler(
      watchPreparedUser: () => Stream<String?>.multi((c) {
        c.add(null);
        final subscription = users.stream.listen(c.add);
        c.onCancel = subscription.cancel;
      }),
      engine: rig.engine,
      outbox: h.outbox,
      connectivity: connectivity,
      logger: RecordingLogger(),
      debounce: debounce,
      interval: interval,
      minBackoff: minBackoff,
      maxBackoff: const Duration(milliseconds: 160),
    )..start();
  });

  tearDown(() async {
    await scheduler.dispose();
    await users.close();
    await h.dispose();
  });

  Future<void> wait(Duration duration) =>
      Future<void>.delayed(duration + const Duration(milliseconds: 40));

  Future<void> createTask(String title) async {
    await h.tasks.createTask(
      TaskDraft(
        details: TaskDetails(
          title: title,
          plannedDuration: const Duration(minutes: 30),
        ),
        schedule: TaskSchedule(
          startDate: LocalDate(2026, 10, 7),
          timeZone: 'UTC',
        ),
      ),
    );
  }

  int pulls() => rig.server.pullCursors.length;

  /// Polls until [condition] holds (timers on a busy CI machine can fire
  /// late), then lets the run finish.
  Future<void> until(bool Function() condition) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!condition()) {
      if (DateTime.now().isAfter(deadline)) {
        fail('condition not met in time');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await rig.engine.idle;
    await pumpEventQueue();
  }

  test('runs once the user is ready, never before', () async {
    await createTask('Before sign-in');
    await wait(debounce);
    expect(pulls(), 0);

    users.add('user-1');
    await pumpEventQueue();
    await rig.engine.idle;

    expect(pulls(), 1);
    expect(await h.outboxRows(), isEmpty);
  });

  test('a burst of changes is pushed once, after the debounce', () async {
    users.add('user-1');
    await pumpEventQueue();
    await rig.engine.idle;
    rig.server.pushed.clear();

    await createTask('One');
    await createTask('Two');
    await createTask('Three');
    expect(rig.server.pushed, isEmpty);

    await until(() => rig.server.pushed.isNotEmpty);
    expect(rig.server.pushed, hasLength(1));
    expect(rig.server.pushed.single, hasLength(3));
  });

  test('waits offline and runs when the network returns', () async {
    connectivity.online = false;
    await pumpEventQueue();
    users.add('user-1');
    await createTask('Offline');
    await wait(debounce);
    expect(pulls(), 0);
    expect(await h.outboxRows(), hasLength(1));

    connectivity.online = true;
    await pumpEventQueue();
    await rig.engine.idle;

    expect(await h.outboxRows(), isEmpty);
  });

  test('a failed run is retried with backoff until it succeeds', () async {
    rig.server.pullError = httpError(503);
    users.add('user-1');
    await pumpEventQueue();
    await rig.engine.idle;
    expect(pulls(), 1);
    await pumpEventQueue();
    expect(scheduler.failures, 1);

    rig.server.pullError = null;
    await until(() => pulls() == 2);
    expect(scheduler.failures, 0);
  });

  test('backoff doubles up to the cap', () {
    expect(scheduler.backoffFor(1), minBackoff);
    expect(scheduler.backoffFor(2), minBackoff * 2);
    expect(scheduler.backoffFor(3), minBackoff * 4);
    expect(scheduler.backoffFor(4), const Duration(milliseconds: 160));
    expect(scheduler.backoffFor(40), const Duration(milliseconds: 160));
  });

  test('runs periodically in the foreground only', () async {
    users.add('user-1');
    await pumpEventQueue();
    await rig.engine.idle;
    await pumpEventQueue();

    await until(() => pulls() == 2);

    scheduler.appPaused();
    await wait(interval);
    expect(pulls(), 2);

    scheduler.appResumed();
    await rig.engine.idle;
    expect(pulls(), 3);
  });

  test('runs on request; nothing runs once signed out', () async {
    users.add('user-1');
    await pumpEventQueue();
    await rig.engine.idle;

    scheduler.requestSync();
    await rig.engine.idle;
    expect(pulls(), 2);

    users.add(null);
    await pumpEventQueue();
    scheduler
      ..requestSync()
      ..appResumed();
    await createTask('Signed out');
    await wait(debounce);
    expect(pulls(), 2);
  });
}
