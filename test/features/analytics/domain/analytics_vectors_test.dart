import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/analytics/domain/services/analytics_calculator.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

/// The server computes the same metrics from the same definitions; both
/// run this vector file (contract §3.3).
const _vectorFile = '../../contracts/vectors/analytics_metrics.json';

const _statuses = {
  'scheduled': OccurrenceStatus.scheduled,
  'in_progress': OccurrenceStatus.inProgress,
  'completed': OccurrenceStatus.completed,
  'skipped': OccurrenceStatus.skipped,
  'cancelled': OccurrenceStatus.cancelled,
};

Duration? _seconds(Object? value) =>
    value == null ? null : Duration(seconds: value as int);

DateTime? _instant(Object? value) =>
    value == null ? null : DateTime.parse(value as String);

ExecutionRecord _record(Map<String, dynamic> json, {Duration? seriesPlanned}) {
  final planned = Duration(seconds: json['planned_sec'] as int);
  return ExecutionRecord(
    occurrenceId: json['occurrence_id'] as String,
    lineageId: json['lineage_id'] as String,
    taskId: 'task-${json['lineage_id']}',
    title: 'Task',
    timeZone: json['time_zone'] as String,
    date: LocalDate.parse(json['date'] as String),
    planned: planned,
    seriesPlanned: seriesPlanned ?? planned,
    status: _statuses[json['status']] ?? OccurrenceStatus.scheduled,
    closedSessionTime: _seconds(json['closed_session_sec']) ?? Duration.zero,
    openSessionStart: _instant(json['open_session_start']),
    scheduledStart: _instant(json['scheduled_start']),
    actualStart: _instant(json['actual_start']),
    actualDuration: _seconds(json['actual_duration_sec']),
    postponeCount: (json['postpone_count'] as int?) ?? 0,
  );
}

void main() {
  final file = File(_vectorFile);
  final calculator = AnalyticsCalculator(TzTimeZoneConverter());

  test('vector file is present', () {
    expect(file.existsSync(), isTrue, reason: 'Run tests from apps/mobile');
  });

  final cases = file.existsSync()
      ? ((jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['cases']
                as List<dynamic>)
            .cast<Map<String, dynamic>>()
      : const <Map<String, dynamic>>[];

  for (final vector in cases) {
    test(vector['name'] as String, () {
      final now = DateTime.parse(vector['now'] as String);
      final expected = vector['expected'] as Map<String, dynamic>;
      final seriesPlanned = _seconds(vector['series_planned_sec']);
      final records = [
        for (final r in (vector['records'] as List<dynamic>))
          _record(r as Map<String, dynamic>, seriesPlanned: seriesPlanned),
      ];

      if (vector['kind'] == 'metrics') {
        final m = calculator.metrics(records, now);
        expect(m.counted, expected['counted']);
        expect(m.completed, expected['completed']);
        expect(m.skipped, expected['skipped']);
        expect(m.missed, expected['missed']);
        expect(m.open, expected['open']);
        expect(m.planned, _seconds(expected['planned_sec']));
        expect(m.tracked, _seconds(expected['tracked_sec']));
        expect(m.measured, expected['measured']);
        expect(m.measuredPlanned, _seconds(expected['measured_planned_sec']));
        expect(m.measuredActual, _seconds(expected['measured_actual_sec']));
        expect(m.timedStarts, expected['timed_starts']);
        expect(m.onTimeStarts, expected['on_time_starts']);
        expect(
          m.medianStartDelay,
          _seconds(expected['median_start_delay_sec']),
        );
        expect(m.postponed, expected['postponed']);
        expect(m.postponements, expected['postponements']);
        _expectRate(m.completionRate, expected['completion_rate']);
        _expectRate(m.onTimeRate, expected['on_time_rate']);
        _expectRate(m.estimateRatio, expected['estimate_ratio']);
      } else {
        final stats = calculator.activity(
          vector['lineage_id'] as String,
          records,
          now,
        );
        expect(stats?.currentStreak, expected['current_streak']);
        expect(stats?.bestStreak, expected['best_streak']);
        expect(
          stats?.suggestion?.suggested,
          _seconds(expected['suggested_sec']),
        );
        expect(stats?.suggestion?.basedOn, expected['suggestion_based_on']);
      }
    });
  }
}

void _expectRate(double? actual, Object? expected) {
  if (expected == null) {
    expect(actual, isNull);
  } else {
    expect(actual, closeTo((expected as num).toDouble(), 1e-9));
  }
}
