import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

void main() {
  final rules = TaskRules(TzTimeZoneConverter());
  final today = LocalDate(2026, 10, 7);

  TaskDraft draft({
    String title = 'Run',
    Duration duration = const Duration(minutes: 30),
    List<Duration> reminders = const [Duration(minutes: 5)],
    LocalDate? start,
    String zone = 'Asia/Kolkata',
    RecurrenceRule rule = RecurrenceRule.once,
  }) => TaskDraft(
    details: TaskDetails(
      title: title,
      plannedDuration: duration,
      reminderOffsets: reminders,
    ),
    schedule: TaskSchedule(
      startDate: start ?? today,
      timeZone: zone,
      rule: rule,
    ),
  );

  Map<String, String> errorsOf(TaskDraft d) =>
      switch (rules.validateDraft(d, today: today)) {
        Ok() => const {},
        Err(failure: ValidationFailure(:final fieldErrors)) => fieldErrors,
        Err(:final failure) => throw TestFailure('Unexpected $failure'),
      };

  test('a valid draft passes', () {
    expect(errorsOf(draft()), isEmpty);
  });

  test('title, duration and reminders', () {
    expect(errorsOf(draft(title: '   ')), {
      TaskFields.title: TaskRuleCodes.required,
    });
    expect(errorsOf(draft(title: 'x' * 201)), {
      TaskFields.title: TaskRuleCodes.tooLong,
    });
    expect(errorsOf(draft(duration: Duration.zero)), {
      TaskFields.plannedDuration: TaskRuleCodes.outOfRange,
    });
    expect(
      errorsOf(
        draft(reminders: const [Duration(minutes: 5), Duration(minutes: 5)]),
      ),
      {TaskFields.reminderOffsets: TaskRuleCodes.invalid},
    );
  });

  test('schedule', () {
    expect(errorsOf(draft(start: today.addDays(-1))), {
      TaskFields.startDate: TaskRuleCodes.inPast,
    });
    expect(errorsOf(draft(zone: 'Not/AZone')), {
      TaskFields.timeZone: TaskRuleCodes.invalid,
    });
    expect(
      errorsOf(
        draft(
          rule: const RecurrenceRule(
            frequency: RecurrenceFrequency.weekly,
            interval: 53,
            weekdays: [0],
          ),
        ),
      ),
      {
        TaskFields.interval: TaskRuleCodes.outOfRange,
        TaskFields.weekdays: TaskRuleCodes.invalid,
      },
    );
    expect(
      errorsOf(
        draft(
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.daily,
            until: today.addDays(5),
            count: 3,
          ),
        ),
      ),
      {TaskFields.count: TaskRuleCodes.conflict},
    );
    expect(
      errorsOf(
        draft(
          rule: RecurrenceRule(
            frequency: RecurrenceFrequency.daily,
            until: today.addDays(-1),
          ),
        ),
      ),
      {TaskFields.until: TaskRuleCodes.outOfRange},
    );
    expect(
      errorsOf(
        draft(
          rule: const RecurrenceRule(
            frequency: RecurrenceFrequency.daily,
            monthDay: 3,
          ),
        ),
      ),
      {TaskFields.monthDay: TaskRuleCodes.invalid},
    );
  });

  test('category names', () {
    expect(rules.validateCategoryName(' Errands ').isOk, isTrue);
    expect(rules.validateCategoryName('  ').isErr, isTrue);
  });
}
