import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/app_status_colors.dart';
import 'package:productivity_planner/core/presentation/duration_format.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/presentation/formatting/analytics_formatters.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/charts/bar_chart.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

AppStatusColors _statusColors(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<AppStatusColors>() ??
      AppStatusColors.fromScheme(theme.colorScheme);
}

/// Under a week every day is labelled; under a month only every 7th from
/// the 1st, so the labels stay readable.
String _dayLabel(BuildContext context, PeriodKind kind, LocalDate date) =>
    switch (kind) {
      PeriodKind.week => formatNarrowWeekday(context, date),
      _ => (date.day - 1) % 7 == 0 ? '${date.day}' : '',
    };

const _countSteps = <double>[1, 2, 5, 10, 20, 50, 100];
const _minuteSteps = <double>[15, 30, 60, 120, 180, 240, 360, 480];

/// Done / skipped / missed / still-to-do per day, stacked. Tapping a day
/// opens it.
class OutcomeChart extends StatelessWidget {
  const OutcomeChart({
    required this.kind,
    required this.days,
    this.onTapDay,
    super.key,
  });

  static const barKeyPrefix = 'outcomes.day.';

  final PeriodKind kind;
  final List<DayMetrics> days;
  final ValueChanged<LocalDate>? onTapDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = _statusColors(context);
    final open = Theme.of(context).colorScheme.outline;
    final groups = [
      for (final day in days)
        BarGroup(
          label: _dayLabel(context, kind, day.date),
          semanticLabel: l10n.barOutcomeSemantics(
            formatDay(context, day.date),
            day.metrics.completed,
            day.metrics.skipped,
            day.metrics.missed,
            day.metrics.open,
          ),
          bars: [
            [
              BarSegment(
                value: day.metrics.completed.toDouble(),
                color: colors.completed,
              ),
              BarSegment(
                value: day.metrics.skipped.toDouble(),
                color: colors.skipped,
              ),
              BarSegment(
                value: day.metrics.missed.toDouble(),
                color: colors.missed,
              ),
              BarSegment(
                value: day.metrics.open.toDouble(),
                color: open,
                outlined: true,
              ),
            ],
          ],
        ),
    ];
    final max = groups.fold<double>(0, (m, g) => g.maxValue > m ? g.maxValue : m);
    final onTap = onTapDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarChart(
          groups: groups,
          scale: ChartScale.fit(max, steps: _countSteps),
          axisLabel: (v) => v.round().toString(),
          groupKeyPrefix: barKeyPrefix,
          onTapGroup: onTap == null ? null : (i) => onTap(days[i].date),
        ),
        const SizedBox(height: AppSpacing.sm),
        ChartLegend(
          items: [
            (label: l10n.outcomeDone, color: colors.completed, outlined: false),
            (label: l10n.outcomeSkipped, color: colors.skipped, outlined: false),
            (label: l10n.outcomeMissed, color: colors.missed, outlined: false),
            (label: l10n.outcomeOpen, color: open, outlined: true),
          ],
        ),
      ],
    );
  }
}

/// Planned (outline) next to tracked (filled) time per day.
class TimeChart extends StatelessWidget {
  const TimeChart({
    required this.kind,
    required this.days,
    this.onTapDay,
    super.key,
  });

  final PeriodKind kind;
  final List<DayMetrics> days;
  final ValueChanged<LocalDate>? onTapDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final planned = scheme.outline;
    final tracked = scheme.primary;
    final groups = [
      for (final day in days)
        BarGroup(
          label: _dayLabel(context, kind, day.date),
          semanticLabel: l10n.barTimeSemantics(
            formatDay(context, day.date),
            formatDuration(day.metrics.planned, l10n),
            formatDuration(day.metrics.tracked, l10n),
          ),
          bars: [
            [
              BarSegment(
                value: day.metrics.planned.inMinutes.toDouble(),
                color: planned,
                outlined: true,
              ),
            ],
            [
              BarSegment(
                value: day.metrics.tracked.inMinutes.toDouble(),
                color: tracked,
              ),
            ],
          ],
        ),
    ];
    final max = groups.fold<double>(0, (m, g) => g.maxValue > m ? g.maxValue : m);
    final onTap = onTapDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarChart(
          groups: groups,
          scale: ChartScale.fit(max, steps: _minuteSteps),
          axisLabel: (v) => formatAxisHours(Duration(minutes: v.round())),
          onTapGroup: onTap == null ? null : (i) => onTap(days[i].date),
        ),
        const SizedBox(height: AppSpacing.sm),
        ChartLegend(
          items: [
            (label: l10n.legendPlanned, color: planned, outlined: true),
            (label: l10n.legendTracked, color: tracked, outlined: false),
          ],
        ),
      ],
    );
  }
}

/// An activity's recent occurrences: the time each took (bar, coloured by
/// outcome) against what was planned (line).
class ActivityHistoryChart extends StatelessWidget {
  const ActivityHistoryChart({required this.history, super.key});

  final List<ExecutionSummary> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = _statusColors(context);
    final markerColor = Theme.of(context).colorScheme.onSurface;
    Color colorOf(ExecutionOutcome outcome) => switch (outcome) {
      ExecutionOutcome.completed => colors.completed,
      ExecutionOutcome.skipped => colors.skipped,
      ExecutionOutcome.missed => colors.missed,
      ExecutionOutcome.open => colors.inProgress,
    };
    final groups = [
      for (final (index, summary) in history.indexed)
        BarGroup(
          // First, last and every 4th date, so labels do not collide.
          label: index == 0 || index == history.length - 1 || index % 4 == 0
              ? formatShortDay(context, summary.record.date)
              : '',
          semanticLabel: l10n.historyBarSemantics(
            formatDay(context, summary.record.date),
            outcomeLabel(summary.outcome, l10n),
            switch (summary.measured) {
              final measured? => formatDuration(measured, l10n),
              null => l10n.notMeasured,
            },
            formatDuration(summary.record.planned, l10n),
          ),
          marker: summary.record.planned.inMinutes.toDouble(),
          bars: [
            [
              BarSegment(
                value: (summary.measured ?? Duration.zero).inMinutes.toDouble(),
                color: colorOf(summary.outcome),
                outlined: summary.outcome == ExecutionOutcome.open,
              ),
            ],
          ],
        ),
    ];
    final max = groups.fold<double>(0, (m, g) => g.maxValue > m ? g.maxValue : m);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BarChart(
          groups: groups,
          scale: ChartScale.fit(max, steps: _minuteSteps),
          axisLabel: (v) => formatAxisHours(Duration(minutes: v.round())),
          markerColor: markerColor,
        ),
        const SizedBox(height: AppSpacing.sm),
        ChartLegend(
          items: [
            (label: l10n.legendTookDone, color: colors.completed, outlined: false),
            (label: l10n.legendPlannedLine, color: markerColor, outlined: false),
          ],
        ),
      ],
    );
  }
}
