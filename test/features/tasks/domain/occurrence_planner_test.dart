import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';
import 'package:productivity_planner/features/tasks/domain/services/recurrence_expander.dart';

const _seriesId = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2a40';

void main() {
  final planner = OccurrencePlanner(
    expander: const RecurrenceExpander(),
    converter: TzTimeZoneConverter(),
  );
  final now = DateTime.utc(2026, 10, 7, 3, 30);
  final today = LocalDate(2026, 10, 7);

  Task task({
    LocalDate? start,
    RecurrenceRule rule = const RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
    ),
    LocalTime? time,
    LocalDate? materializedThrough,
    LocalDate? endedOn,
    String zone = 'Europe/Berlin',
  }) => Task(
    id: _seriesId,
    lineageId: _seriesId,
    title: 'Run',
    plannedDuration: const Duration(minutes: 30),
    schedule: TaskSchedule(
      startDate: start ?? today,
      startTime: time,
      timeZone: zone,
      rule: rule,
    ),
    materializedThrough: materializedThrough,
    endedOn: endedOn,
    createdAt: now,
    updatedAt: now,
  );

  test('a new daily series is planned from today to the horizon', () {
    final plan = planner.plan(task(), today: today, now: now);
    expect(plan?.occurrences, hasLength(OccurrencePlanner.horizonDays + 1));
    expect(plan?.occurrences.first.originalDate, today);
    expect(plan?.through, today.addDays(OccurrencePlanner.horizonDays));
  });

  test('ids are the deterministic occurrence ids', () {
    final first = planner.plan(task(), today: today, now: now)?.occurrences.first;
    expect(
      first?.id,
      occurrenceIdFor(
        seriesId: _seriesId,
        originalLocalDate: DateTime.utc(2026, 10, 7),
      ),
    );
  });

  test('a series started in the past does not create missed occurrences', () {
    final plan = planner.plan(
      task(start: today.addDays(-10)),
      today: today,
      now: now,
    );
    expect(plan?.occurrences.first.originalDate, today);
  });

  test('continues after the watermark and returns null when up to date', () {
    final plan = planner.plan(
      task(materializedThrough: today.addDays(10)),
      today: today,
      now: now,
    );
    expect(plan?.occurrences.map((o) => o.originalDate), [
      for (var i = 11; i <= OccurrencePlanner.horizonDays; i++)
        today.addDays(i),
    ]);
    expect(
      planner.plan(
        task(materializedThrough: today.addDays(OccurrencePlanner.horizonDays)),
        today: today,
        now: now,
      ),
      isNull,
    );
  });

  test('back-fills days missed while the app was closed, up to a limit', () {
    final plan = planner.plan(
      task(start: today.addDays(-100), materializedThrough: today.addDays(-60)),
      today: today,
      now: now,
    );
    expect(
      plan?.occurrences.first.originalDate,
      today.addDays(-OccurrencePlanner.backfillDays),
    );
  });

  test('stops at the end date', () {
    final plan = planner.plan(
      task(endedOn: today.addDays(2)),
      today: today,
      now: now,
    );
    expect(plan?.occurrences, hasLength(3));
  });

  test('converts start times through the series zone (DST night)', () {
    final o = planner.build(
      task(time: LocalTime(2, 30)),
      LocalDate(2026, 3, 29),
      now: now,
    );
    expect(o.scheduledStart, DateTime.utc(2026, 3, 29, 1, 30));
    expect(o.originalStart, o.scheduledStart);
  });

  test('any-time series have no start', () {
    final o = planner.build(task(), today, now: now);
    expect(o.scheduledStart, isNull);
  });
}
