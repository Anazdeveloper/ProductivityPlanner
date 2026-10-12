import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/task_plan_policy.dart';

import '../../../helpers/fake_feature_access.dart';

void main() {
  final today = LocalDate(2026, 10, 8);
  const daily = RecurrenceRule(frequency: RecurrenceFrequency.daily);

  Task task(
    String id, {
    RecurrenceRule rule = RecurrenceRule.once,
    LocalDate? start,
    LocalDate? endedOn,
  }) => Task(
    id: id,
    lineageId: id,
    title: id,
    plannedDuration: const Duration(minutes: 30),
    schedule: TaskSchedule(
      startDate: start ?? today,
      timeZone: 'Asia/Kolkata',
      rule: rule,
    ),
    endedOn: endedOn,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  TaskSchedule schedule([RecurrenceRule rule = RecurrenceRule.once]) =>
      TaskSchedule(startDate: today, timeZone: 'Asia/Kolkata', rule: rule);

  const free = TaskPlanPolicy(
    FakeFeatureAccess(
      limits: {LimitKey.activeSeries: 3, LimitKey.recurringSeries: 1},
    ),
  );

  test('active tasks: ended and past one-offs do not count', () {
    final tasks = [
      task('a'),
      task('b', rule: daily),
      task('past', start: today.addDays(-1)),
      task('ended', rule: daily, endedOn: today.addDays(-1)),
    ];
    expect(free.check(schedule(), tasks: tasks, today: today), isNull);
    expect(
      free.check(schedule(), tasks: [...tasks, task('c')], today: today),
      const Failure.limitReached(limit: LimitKey.activeSeries, allowed: 3),
    );
  });

  test('repeating tasks have their own limit', () {
    expect(
      free.check(schedule(daily), tasks: [task('b', rule: daily)], today: today),
      const Failure.limitReached(limit: LimitKey.recurringSeries, allowed: 1),
    );
  });

  test('editing a task is not blocked by limits it already counts in', () {
    final tasks = [task('a'), task('b', rule: daily), task('c')];
    expect(
      free.check(
        schedule(daily),
        tasks: tasks,
        today: today,
        editing: tasks[1],
      ),
      isNull,
      reason: 'already repeating, at the limits',
    );
    expect(
      free.check(schedule(daily), tasks: tasks, today: today, editing: tasks[0]),
      const Failure.limitReached(limit: LimitKey.recurringSeries, allowed: 1),
      reason: 'becoming repeating adds one',
    );
  });

  test('"every N" needs advanced recurrence; an unchanged one is kept', () {
    const everyOther = RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
    );
    expect(
      free.check(schedule(everyOther), tasks: const [], today: today),
      const Failure.entitlementRequired(feature: Feature.advancedRecurrence),
    );
    final existing = task('x', rule: everyOther);
    expect(
      free.check(
        schedule(everyOther),
        tasks: [existing],
        today: today,
        editing: existing,
      ),
      isNull,
    );
    const pro = TaskPlanPolicy(
      FakeFeatureAccess(features: {Feature.advancedRecurrence}),
    );
    expect(pro.check(schedule(everyOther), tasks: const [], today: today), isNull);
  });
}
