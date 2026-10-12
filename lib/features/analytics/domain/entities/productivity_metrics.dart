import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';

part 'productivity_metrics.freezed.dart';

/// How an occurrence turned out, as of a given moment. Cancelled
/// occurrences are not counted at all (the person said they no longer
/// apply).
enum ExecutionOutcome {
  completed,
  skipped,

  /// Its day ended without it being started or resolved.
  missed,

  /// Still to do: today or later, or started and not finished.
  open,
}

/// Aggregates over a set of occurrences (the brief's `ProductivityMetric`).
/// Definitions are shared with the server: contract §3.3.
@freezed
abstract class PeriodMetrics with _$PeriodMetrics {
  const factory PeriodMetrics({
    /// Occurrences that count: everything except cancelled.
    @Default(0) int counted,
    @Default(0) int completed,
    @Default(0) int skipped,
    @Default(0) int missed,
    @Default(0) int open,

    /// Expected time of all counted occurrences.
    @Default(Duration.zero) Duration planned,

    /// Measured time: the actual duration of completed occurrences plus the
    /// session time of started, unfinished ones.
    @Default(Duration.zero) Duration tracked,

    /// Completed occurrences with a measured duration, and their planned
    /// and actual totals (the estimate accuracy inputs).
    @Default(0) int measured,
    @Default(Duration.zero) Duration measuredPlanned,
    @Default(Duration.zero) Duration measuredActual,

    /// Started occurrences that had a start time, and how many of those
    /// started within the grace period.
    @Default(0) int timedStarts,
    @Default(0) int onTimeStarts,

    /// Median of actual − scheduled start over [timedStarts]; negative
    /// means early.
    Duration? medianStartDelay,

    /// Occurrences moved at least once, and the total number of moves.
    @Default(0) int postponed,
    @Default(0) int postponements,
  }) = _PeriodMetrics;

  const PeriodMetrics._();

  static const empty = PeriodMetrics();

  /// Occurrences whose outcome is known: done, skipped or missed.
  int get decided => completed + skipped + missed;

  /// Completed share of the decided occurrences, 0..1. Null when nothing
  /// was decided yet, so an unfinished day is not shown as a failure.
  double? get completionRate => decided == 0 ? null : completed / decided;

  /// 0..1; null without timed starts.
  double? get onTimeRate =>
      timedStarts == 0 ? null : onTimeStarts / timedStarts;

  /// Actual ÷ planned over measured completions (1.2 = took 20 % longer
  /// than planned). Null without measurements.
  double? get estimateRatio => measured == 0 || measuredPlanned == Duration.zero
      ? null
      : measuredActual.inSeconds / measuredPlanned.inSeconds;

  bool get isEmpty => counted == 0;
}

/// One day's metrics, for the daily bars of a week or month.
@freezed
abstract class DayMetrics with _$DayMetrics {
  const factory DayMetrics({
    required LocalDate date,
    required PeriodMetrics metrics,
  }) = _DayMetrics;
}

/// One occurrence with its outcome, for lists and the activity history.
@freezed
abstract class ExecutionSummary with _$ExecutionSummary {
  const factory ExecutionSummary({
    required ExecutionRecord record,
    required ExecutionOutcome outcome,

    /// The actual duration if completed and measured, else session time so
    /// far; null when nothing was measured.
    Duration? measured,
  }) = _ExecutionSummary;
}

/// One activity's share of a period ("By activity").
@freezed
abstract class ActivityBreakdown with _$ActivityBreakdown {
  const factory ActivityBreakdown({
    required String lineageId,

    /// The most recent title (an activity can be renamed).
    required String title,
    required PeriodMetrics metrics,
    Category? category,
  }) = _ActivityBreakdown;
}

/// Everything the Day/Week/Month screen shows for one period.
@freezed
abstract class AnalyticsReport with _$AnalyticsReport {
  const factory AnalyticsReport({
    required AnalyticsPeriod period,
    required PeriodMetrics metrics,

    /// The period before, for "vs last week".
    required PeriodMetrics previous,

    /// One entry per day of the period, in order.
    required List<DayMetrics> days,

    /// Activities with counted occurrences, most tracked time first.
    required List<ActivityBreakdown> activities,

    /// The period's occurrences in date and start order (the Day view's
    /// plan-vs-actual list).
    required List<ExecutionSummary> executions,
  }) = _AnalyticsReport;
}

/// A better expected duration, learned from recent measured completions.
@freezed
abstract class DurationSuggestion with _$DurationSuggestion {
  const factory DurationSuggestion({
    required Duration current,
    required Duration suggested,

    /// How many measured completions it is based on.
    required int basedOn,
  }) = _DurationSuggestion;
}

/// Task-specific analytics for one activity (lineage).
@freezed
abstract class ActivityStats with _$ActivityStats {
  const factory ActivityStats({
    required String lineageId,
    required String title,

    /// The series carrying the current schedule (where a suggestion
    /// applies).
    required String currentTaskId,

    /// Its expected duration.
    required Duration currentPlanned,
    required PeriodMetrics metrics,

    /// Completed occurrences in a row, up to the latest decided one. A
    /// skip or a miss ends a streak; open ones are ignored.
    required int currentStreak,
    required int bestStreak,

    /// The most recent occurrences up to today, oldest first.
    required List<ExecutionSummary> history,
    Category? category,
    DurationSuggestion? suggestion,
  }) = _ActivityStats;
}
