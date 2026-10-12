import 'dart:math' as math;

import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

/// Turns execution records into metrics. Pure; definitions in contract
/// §3.3, pinned by `contracts/vectors/analytics_metrics.json`.
///
/// Outcomes depend on the moment: an occurrence planned for yesterday that
/// was never started is "missed" today, so every method takes `now` and
/// judges each record's day in its own series' zone.
final class AnalyticsCalculator {
  const AnalyticsCalculator(this._converter);

  /// A start up to this long after the scheduled start counts as on time.
  static const onTimeGrace = Duration(minutes: 10);

  /// Occurrences in an activity's history chart.
  static const historyLength = 14;

  final TimeZoneConverter _converter;

  /// Metrics over [records] (cancelled ones are ignored).
  PeriodMetrics metrics(Iterable<ExecutionRecord> records, DateTime now) {
    final today = _TodayByZone(_converter, now);
    final accumulator = _Accumulator(now);
    for (final record in records) {
      final outcome = _outcome(record, today);
      if (outcome != null) accumulator.add(record, outcome);
    }
    return accumulator.build();
  }

  /// The report for [period]. [records] must cover [period] and the period
  /// before it (for the comparison); others are ignored.
  AnalyticsReport report(
    AnalyticsPeriod period,
    List<ExecutionRecord> records,
    DateTime now,
  ) {
    final today = _TodayByZone(_converter, now);
    final previousPeriod = period.previous;
    final current = _Accumulator(now);
    final previous = _Accumulator(now);
    final byDay = {for (final day in period.days) day: _Accumulator(now)};
    final byActivity = <String, _ActivityAccumulator>{};
    final executions = <ExecutionSummary>[];

    for (final record in records) {
      final outcome = _outcome(record, today);
      if (outcome == null) continue;
      if (previousPeriod.contains(record.date)) {
        previous.add(record, outcome);
      }
      if (!period.contains(record.date)) continue;
      current.add(record, outcome);
      byDay[record.date]?.add(record, outcome);
      (byActivity[record.lineageId] ??= _ActivityAccumulator(now)).add(
        record,
        outcome,
      );
      executions.add(_summary(record, outcome, now));
    }

    final activities = [
      for (final MapEntry(key: lineageId, value: activity)
          in byActivity.entries)
        activity.build(lineageId),
    ]..sort(_byTrackedTime);
    executions.sort((a, b) => _chronological(a.record, b.record));

    return AnalyticsReport(
      period: period,
      metrics: current.build(),
      previous: previous.build(),
      days: [
        for (final day in period.days)
          DayMetrics(
            date: day,
            metrics: byDay[day]?.build() ?? PeriodMetrics.empty,
          ),
      ],
      activities: activities,
      executions: executions,
    );
  }

  /// Task-specific analytics for [lineageId]. [records] are the activity's
  /// occurrences; those after today count only for finding the series
  /// that carries the current schedule. Null when there are none.
  ActivityStats? activity(
    String lineageId,
    List<ExecutionRecord> records,
    DateTime now,
  ) {
    final today = _TodayByZone(_converter, now);
    final own = [
      for (final record in records)
        if (record.lineageId == lineageId &&
            record.status != OccurrenceStatus.cancelled)
          record,
    ]..sort(_chronological);
    if (own.isEmpty) return null;
    final latest = own.last;

    final accumulator = _Accumulator(now);
    final past = <ExecutionSummary>[];
    for (final record in own) {
      if (record.date > today.of(record.timeZone)) continue;
      final outcome = _outcome(record, today);
      if (outcome == null) continue;
      accumulator.add(record, outcome);
      past.add(_summary(record, outcome, now));
    }
    final latestPast = past.isEmpty ? latest : past.last.record;
    final (:current, :best) = _streaks(past);

    return ActivityStats(
      lineageId: lineageId,
      title: latestPast.title,
      category: latestPast.category,
      currentTaskId: latest.taskId,
      currentPlanned: latest.seriesPlanned,
      metrics: accumulator.build(),
      currentStreak: current,
      bestStreak: best,
      history: past.length <= historyLength
          ? past
          : past.sublist(past.length - historyLength),
      suggestion: suggestDuration(past, current: latest.seriesPlanned),
    );
  }

  /// Fewer measured completions than this and no duration is suggested.
  static const suggestionMinimumSamples = 5;

  /// The most recent measured completions a suggestion looks at.
  static const suggestionSamples = 10;

  /// Suggested durations are rounded to this step.
  static const suggestionStep = Duration(minutes: 5);

  /// A better expected duration: the median of the most recent measured
  /// completions in [history] (oldest first), rounded to 5 minutes. Null
  /// with too few measurements, or when the plan is already within 15 %
  /// (and 5 minutes) of it.
  DurationSuggestion? suggestDuration(
    List<ExecutionSummary> history, {
    required Duration current,
  }) {
    final samples = [
      for (final summary in history.reversed)
        if (summary.outcome == ExecutionOutcome.completed)
          if (summary.record.actualDuration case final duration?) duration,
    ].take(suggestionSamples).toList();
    if (samples.length < suggestionMinimumSamples) return null;

    final median = medianDuration(samples);
    if (median == null) return null;
    final step = suggestionStep.inSeconds;
    final roundedSeconds = (median.inSeconds + step ~/ 2) ~/ step * step;
    final rounded = Duration(
      seconds: math.min(
        math.max(roundedSeconds, step),
        const Duration(hours: 24).inSeconds,
      ),
    );
    final difference = (rounded - current).abs();
    if (difference < suggestionStep ||
        difference.inSeconds < current.inSeconds * 0.15) {
      return null;
    }
    return DurationSuggestion(
      current: current,
      suggested: rounded,
      basedOn: samples.length,
    );
  }

  /// Null for a cancelled occurrence (not counted).
  ExecutionOutcome? _outcome(ExecutionRecord record, _TodayByZone today) =>
      switch (record.status) {
        OccurrenceStatus.cancelled => null,
        OccurrenceStatus.completed => ExecutionOutcome.completed,
        OccurrenceStatus.skipped => ExecutionOutcome.skipped,
        OccurrenceStatus.inProgress => ExecutionOutcome.open,
        OccurrenceStatus.scheduled =>
          record.date < today.of(record.timeZone)
              ? ExecutionOutcome.missed
              : ExecutionOutcome.open,
      };

  ExecutionSummary _summary(
    ExecutionRecord record,
    ExecutionOutcome outcome,
    DateTime now,
  ) {
    final sessions = record.sessionTime(now);
    return ExecutionSummary(
      record: record,
      outcome: outcome,
      measured: outcome == ExecutionOutcome.completed
          ? record.actualDuration
          : (sessions > Duration.zero ? sessions : null),
    );
  }

  ({int current, int best}) _streaks(List<ExecutionSummary> ordered) {
    var run = 0;
    var best = 0;
    for (final summary in ordered) {
      switch (summary.outcome) {
        case ExecutionOutcome.completed:
          run++;
          if (run > best) best = run;
        case ExecutionOutcome.skipped || ExecutionOutcome.missed:
          run = 0;
        case ExecutionOutcome.open:
          break;
      }
    }
    return (current: run, best: best);
  }

  static int _byTrackedTime(ActivityBreakdown a, ActivityBreakdown b) {
    final byTracked = b.metrics.tracked.compareTo(a.metrics.tracked);
    if (byTracked != 0) return byTracked;
    final byCompleted = b.metrics.completed.compareTo(a.metrics.completed);
    if (byCompleted != 0) return byCompleted;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  static int _chronological(ExecutionRecord a, ExecutionRecord b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    final startA = a.scheduledStart;
    final startB = b.scheduledStart;
    if (startA != null && startB != null) {
      final byStart = startA.compareTo(startB);
      if (byStart != 0) return byStart;
    } else if (startA != null) {
      return -1;
    } else if (startB != null) {
      return 1;
    }
    final byTitle = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    return byTitle != 0 ? byTitle : a.occurrenceId.compareTo(b.occurrenceId);
  }
}

/// The middle value (mean of the two middle values for an even count);
/// null for an empty list.
Duration? medianDuration(List<Duration> values) {
  if (values.isEmpty) return null;
  final sorted = [...values]..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];
  return Duration(
    microseconds:
        (sorted[middle - 1].inMicroseconds + sorted[middle].inMicroseconds) ~/
        2,
  );
}

/// "Today" per series zone, computed once per zone.
final class _TodayByZone {
  _TodayByZone(this._converter, this._now);

  final TimeZoneConverter _converter;
  final DateTime _now;
  final _cache = <String, LocalDate>{};

  LocalDate of(String zone) => _cache.putIfAbsent(
    zone,
    () => _converter.localDate(
      _now,
      _converter.isValidZone(zone) ? zone : 'UTC',
    ),
  );
}

final class _Accumulator {
  _Accumulator(this._now);

  final DateTime _now;
  var _counted = 0;
  var _completed = 0;
  var _skipped = 0;
  var _missed = 0;
  var _open = 0;
  Duration _planned = Duration.zero;
  Duration _tracked = Duration.zero;
  var _measured = 0;
  Duration _measuredPlanned = Duration.zero;
  Duration _measuredActual = Duration.zero;
  var _onTime = 0;
  final _delays = <Duration>[];
  var _postponed = 0;
  var _postponements = 0;

  void add(ExecutionRecord record, ExecutionOutcome outcome) {
    _counted++;
    _planned += record.planned;
    if (record.postponeCount > 0) {
      _postponed++;
      _postponements += record.postponeCount;
    }
    if (record.startDelay case final delay?) {
      _delays.add(delay);
      if (delay <= AnalyticsCalculator.onTimeGrace) _onTime++;
    }
    switch (outcome) {
      case ExecutionOutcome.completed:
        _completed++;
        if (record.actualDuration case final actual?) {
          _tracked += actual;
          _measured++;
          _measuredPlanned += record.planned;
          _measuredActual += actual;
        }
      case ExecutionOutcome.skipped:
        _skipped++;
      case ExecutionOutcome.missed:
        _missed++;
      case ExecutionOutcome.open:
        _open++;
        if (record.status == OccurrenceStatus.inProgress) {
          _tracked += record.sessionTime(_now);
        }
    }
  }

  PeriodMetrics build() => PeriodMetrics(
    counted: _counted,
    completed: _completed,
    skipped: _skipped,
    missed: _missed,
    open: _open,
    planned: _planned,
    tracked: _tracked,
    measured: _measured,
    measuredPlanned: _measuredPlanned,
    measuredActual: _measuredActual,
    timedStarts: _delays.length,
    onTimeStarts: _onTime,
    medianStartDelay: medianDuration(_delays),
    postponed: _postponed,
    postponements: _postponements,
  );
}

final class _ActivityAccumulator {
  _ActivityAccumulator(DateTime now) : _metrics = _Accumulator(now);

  final _Accumulator _metrics;
  ExecutionRecord? _latest;

  void add(ExecutionRecord record, ExecutionOutcome outcome) {
    _metrics.add(record, outcome);
    final latest = _latest;
    if (latest == null || record.date >= latest.date) _latest = record;
  }

  ActivityBreakdown build(String lineageId) {
    final latest = _latest;
    return ActivityBreakdown(
      lineageId: lineageId,
      title: latest?.title ?? '',
      category: latest?.category,
      metrics: _metrics.build(),
    );
  }
}
