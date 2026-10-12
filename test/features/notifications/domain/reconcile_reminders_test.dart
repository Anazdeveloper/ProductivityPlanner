import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/services/reminder_planner.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reminder_actions.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';

import '../../../helpers/fake_notifications.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/test_database.dart';

const _zone = 'Asia/Kolkata';

final class _Zone implements HomeTimeZone {
  @override
  Future<String> current() async => _zone;
}

/// Reconciliation against the real tasks data layer (in-memory database).
void main() {
  late FixedClock clock;
  late TasksTestHarness h;
  late FakeReminderScheduler scheduler;
  late FakeNotificationPermissions permissions;
  late FakeReminderSettings settings;
  late ReconcileReminders reconcile;
  final today = LocalDate(2026, 10, 7);

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 2)); // 07:30 in Kolkata
    h = TasksTestHarness(clock: clock);
    scheduler = FakeReminderScheduler();
    permissions = FakeNotificationPermissions();
    settings = FakeReminderSettings();
    reconcile = ReconcileReminders(
      tasks: h.tasks,
      scheduler: scheduler,
      permissions: permissions,
      settings: settings,
      planner: const ReminderPlanner(),
      homeTimeZone: _Zone(),
      converter: h.converter,
      clock: clock,
    );
  });

  tearDown(() => h.dispose());

  Future<ReconcileReport> run() async => switch (await reconcile(
    const NoParams(),
  )) {
    Ok(:final value) => value,
    Err(:final failure) => throw TestFailure('$failure'),
  };

  Future<String> createDaily({LocalTime? time, String title = 'Run'}) async {
    final created = await h.tasks.createTask(
      TaskDraft(
        details: TaskDetails(
          title: title,
          plannedDuration: const Duration(minutes: 30),
        ),
        schedule: TaskSchedule(
          startDate: today,
          startTime: time ?? LocalTime(9, 0),
          timeZone: _zone,
          rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        ),
      ),
    );
    return created.valueOrNull?.id ?? (throw TestFailure('not created'));
  }

  Future<String> todaysOccurrence() async {
    final items = (await h.tasks.watchAgenda(from: today, to: today).first)
        .valueOrNull;
    return items?.single.occurrence.id ?? (throw TestFailure('none'));
  }

  test('schedules a reminder for every upcoming occurrence', () async {
    await createDaily();

    final report = await run();

    // Today through the 14-day horizon, 5 minutes before 09:00 IST.
    expect(report.scheduled, 15);
    expect(scheduler.reminders, hasLength(15));
    final first = scheduler.reminders.reduce(
      (a, b) => a.fireAt.isBefore(b.fireAt) ? a : b,
    );
    expect(first.fireAt, DateTime.utc(2026, 10, 7, 3, 25));
    expect(first.taskTitle, 'Run');
  });

  test('a second run changes nothing', () async {
    await createDaily();
    await run();
    final calls = scheduler.scheduleCalls;

    final report = await run();

    expect(report.kept, 15);
    expect(report.scheduled, 0);
    expect(report.cancelled, 0);
    expect(scheduler.scheduleCalls, calls);
  });

  test('completing or postponing replaces exactly that reminder', () async {
    await createDaily();
    await run();
    final occurrence = await todaysOccurrence();

    await h.tasks.applyAction(occurrence, const CompleteOccurrence());
    var report = await run();
    expect(report.cancelled, 1);
    expect(scheduler.reminders.map((r) => r.occurrenceId), isNot(contains(occurrence)));

    // Tomorrow's moves to 18:00: its reminder is replaced, not duplicated.
    final tomorrow = today.addDays(1);
    final items = (await h.tasks
            .watchAgenda(from: tomorrow, to: tomorrow)
            .first)
        .valueOrNull;
    final next = items?.single.occurrence.id ?? '';
    await h.tasks.applyAction(
      next,
      PostponeOccurrence(toDate: tomorrow, toTime: LocalTime(18, 0)),
    );
    report = await run();
    expect(report.cancelled, 1);
    expect(report.scheduled, 1);
    final moved = scheduler.reminders.singleWhere((r) => r.occurrenceId == next);
    expect(moved.fireAt, DateTime.utc(2026, 10, 8, 12, 25));
  });

  test('deleting the task cancels its reminders', () async {
    final taskId = await createDaily();
    await run();

    await h.tasks.deleteTask(taskId);
    final report = await run();

    expect(report.cancelled, 15);
    expect(scheduler.scheduled, isEmpty);
  });

  test('switching reminders off, or no permission, schedules nothing', () async {
    await createDaily();
    await run();

    await settings.setRemindersEnabled(enabled: false);
    var report = await run();
    expect(scheduler.scheduled, isEmpty);
    expect(report.wanted, 0);

    await settings.setRemindersEnabled(enabled: true);
    permissions.permission = NotificationPermission.notDetermined;
    report = await run();
    expect(scheduler.scheduled, isEmpty);
    expect(report.wanted, 15, reason: 'used to decide whether to ask');
    expect(report.active, isFalse);
  });

  test('a snooze survives until the task is done', () async {
    await createDaily(time: LocalTime(8, 0));
    await run();
    final occurrence = await todaysOccurrence();
    final handle = HandleReminderAction(
      tasks: h.tasks,
      scheduler: scheduler,
      reconcile: reconcile,
      clock: clock,
    );

    await handle(
      ReminderActionParams(
        occurrenceId: occurrence,
        action: ReminderAction.snooze,
      ),
    );
    expect(scheduler.snoozes.single.fireAt, DateTime.utc(2026, 10, 7, 2, 10));
    expect(scheduler.snoozes.single.kind, ReminderKind.snooze);

    await handle(
      ReminderActionParams(
        occurrenceId: occurrence,
        action: ReminderAction.done,
      ),
    );
    expect(scheduler.snoozes, isEmpty);
    final stored = (await h.tasks.watchAgendaItem(occurrence).first)
        .valueOrNull;
    expect(stored?.occurrence.status, OccurrenceStatus.completed);
    expect(stored?.occurrence.actualDuration, isNull);
    expect((await h.outboxRows()).last.type, 'occurrence.complete');

    // Pressing Done again (e.g. on a second notification) is harmless.
    final again = await handle(
      ReminderActionParams(
        occurrenceId: occurrence,
        action: ReminderAction.done,
      ),
    );
    expect(again.isOk, isTrue);
  });
}
