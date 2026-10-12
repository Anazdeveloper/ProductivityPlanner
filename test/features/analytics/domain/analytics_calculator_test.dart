import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/domain/services/analytics_calculator.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

import '../../../helpers/execution_records.dart';

void main() {
  final calculator = AnalyticsCalculator(TzTimeZoneConverter());
  // Wednesday 7 October 2026, 12:00 in Kolkata.
  final now = DateTime.utc(2026, 10, 7, 6, 30);
  final today = LocalDate(2026, 10, 7);
  final week = AnalyticsPeriod.containing(PeriodKind.week, today);

  group('report', () {
    final records = [
      // Last week
      execution(
        id: 'p1',
        date: LocalDate(2026, 9, 30),
        status: OccurrenceStatus.completed,
      ),
      execution(id: 'p2', date: LocalDate(2026, 10, 1)), // missed
      // This week
      execution(
        id: 'r1',
        date: LocalDate(2026, 10, 5),
        status: OccurrenceStatus.completed,
        actual: const Duration(minutes: 40),
      ),
      execution(
        id: 'r2',
        date: LocalDate(2026, 10, 6),
        status: OccurrenceStatus.skipped,
      ),
      execution(
        id: 'w1',
        date: LocalDate(2026, 10, 7),
        lineageId: 'write',
        title: 'Write',
        status: OccurrenceStatus.completed,
        actual: const Duration(hours: 2),
        planned: const Duration(hours: 1),
      ),
      execution(id: 'r3', date: LocalDate(2026, 10, 8)), // open
      // Outside both periods
      execution(id: 'x', date: LocalDate(2026, 10, 12)),
    ];
    final report = calculator.report(week, records, now);

    test('totals cover the period only', () {
      expect(report.metrics.counted, 4);
      expect(report.metrics.completed, 2);
      expect(report.metrics.skipped, 1);
      expect(report.metrics.open, 1);
      expect(report.metrics.completionRate, closeTo(2 / 3, 1e-9));
    });

    test('the previous period is computed for comparison', () {
      expect(report.previous.counted, 2);
      expect(report.previous.completionRate, 0.5);
    });

    test('one entry per day, empty days included', () {
      expect(report.days, hasLength(7));
      expect(report.days.first.date, LocalDate(2026, 10, 5));
      expect(report.days.first.metrics.completed, 1);
      expect(report.days.last.metrics, PeriodMetrics.empty);
    });

    test('activities are ordered by tracked time', () {
      expect(
        report.activities.map((a) => a.lineageId),
        ['write', 'run'],
      );
      expect(report.activities.first.title, 'Write');
      expect(report.activities.last.metrics.counted, 3);
    });

    test('executions are in date order with outcomes', () {
      expect(
        report.executions.map((e) => e.record.occurrenceId),
        ['r1', 'r2', 'w1', 'r3'],
      );
      expect(report.executions.first.measured, const Duration(minutes: 40));
      expect(report.executions.last.outcome, ExecutionOutcome.open);
    });
  });

  group('activity', () {
    test('null for an activity with no occurrences', () {
      expect(calculator.activity('nope', const [], now), isNull);
    });

    test('history keeps the last 14 occurrences up to today', () {
      final records = [
        for (var i = 0; i < 20; i++)
          execution(
            id: 'o$i',
            date: today.addDays(i - 19),
            status: OccurrenceStatus.completed,
          ),
        execution(id: 'future', date: today.addDays(3)),
      ];
      final stats = calculator.activity('run', records, now);
      expect(stats?.history, hasLength(AnalyticsCalculator.historyLength));
      expect(stats?.history.last.record.occurrenceId, 'o19');
      expect(stats?.currentStreak, 20);
      expect(stats?.metrics.counted, 20, reason: 'the future one is excluded');
    });

    test('the current schedule comes from the latest series', () {
      final records = [
        execution(
          id: 'old',
          date: LocalDate(2026, 10, 1),
          title: 'Run',
          status: OccurrenceStatus.completed,
        ),
        execution(
          id: 'new',
          date: LocalDate(2026, 10, 9),
          title: 'Morning run',
          seriesPlanned: const Duration(minutes: 45),
        ).copyWith(taskId: 'task-run-2'),
      ];
      final stats = calculator.activity('run', records, now);
      expect(stats?.currentTaskId, 'task-run-2');
      expect(stats?.currentPlanned, const Duration(minutes: 45));
      expect(stats?.title, 'Run', reason: 'title of the latest past one');
    });
  });

  group('suggestDuration', () {
    List<ExecutionSummary> completions(List<int> minutes) => [
      for (final (i, m) in minutes.indexed)
        ExecutionSummary(
          record: execution(
            id: 'c$i',
            date: today.addDays(i - minutes.length),
            status: OccurrenceStatus.completed,
            actual: Duration(minutes: m),
          ),
          outcome: ExecutionOutcome.completed,
          measured: Duration(minutes: m),
        ),
    ];

    test('needs five measured completions', () {
      expect(
        calculator.suggestDuration(
          completions([50, 50, 50, 50]),
          current: const Duration(minutes: 30),
        ),
        isNull,
      );
    });

    test('rounds the median to 5 minutes', () {
      final suggestion = calculator.suggestDuration(
        completions([41, 44, 47, 52, 39]),
        current: const Duration(minutes: 30),
      );
      expect(suggestion?.suggested, const Duration(minutes: 45));
      expect(suggestion?.basedOn, 5);
    });

    test('uses only the 10 most recent', () {
      final suggestion = calculator.suggestDuration(
        completions([120, 120, 120, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20]),
        current: const Duration(minutes: 60),
      );
      expect(suggestion?.suggested, const Duration(minutes: 20));
      expect(suggestion?.basedOn, 10);
    });

    test('suggests shorter plans too', () {
      final suggestion = calculator.suggestDuration(
        completions([10, 12, 11, 9, 10]),
        current: const Duration(minutes: 30),
      );
      expect(suggestion?.suggested, const Duration(minutes: 10));
    });
  });

  test('medianDuration', () {
    expect(medianDuration(const []), isNull);
    expect(
      medianDuration(const [Duration(minutes: 3), Duration(minutes: 1)]),
      const Duration(minutes: 2),
    );
    expect(
      medianDuration(const [
        Duration(minutes: 9),
        Duration(minutes: 1),
        Duration(minutes: 4),
      ]),
      const Duration(minutes: 4),
    );
  });
}
