import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/duration_format.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/presentation/formatting/analytics_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// One number with its label and a line of context. Read as one sentence
/// by screen readers.
class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.detail,
    super.key,
  });

  final String label;
  final String value;
  final String? detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detail = this.detail;
    return Semantics(
      container: true,
      child: MergeSemantics(
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(value, style: theme.textTheme.headlineSmall),
                if (detail != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tiles in two columns (three on wide screens).
class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.tiles, super.key});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        const gap = AppSpacing.sm;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

/// The completion tile: rate, "x of y done", and the change from the
/// previous period when [previous] is given.
MetricTile completionTile(
  BuildContext context,
  PeriodMetrics metrics, {
  PeriodMetrics? previous,
}) {
  final l10n = AppLocalizations.of(context);
  final rate = metrics.completionRate;
  final before = previous?.completionRate;
  final lines = [
    if (rate == null)
      l10n.nothingDueYet
    else
      l10n.progressDone(metrics.completed, metrics.decided),
    if (rate != null && before != null) _delta(l10n, rate, before),
  ];
  return MetricTile(
    key: const Key('metric.completion'),
    icon: Icons.check_circle_outline,
    label: l10n.metricCompletion,
    value: rate == null ? l10n.noValue : formatPercent(context, rate),
    detail: lines.join('\n'),
  );
}

String _delta(AppLocalizations l10n, double rate, double before) {
  final points = ((rate - before) * 100).round();
  if (points == 0) return l10n.deltaSame;
  return points > 0 ? l10n.deltaUp(points) : l10n.deltaDown(-points);
}

MetricTile trackedTile(BuildContext context, PeriodMetrics metrics) {
  final l10n = AppLocalizations.of(context);
  return MetricTile(
    key: const Key('metric.tracked'),
    icon: Icons.timer_outlined,
    label: l10n.metricTracked,
    value: formatDuration(metrics.tracked, l10n),
    detail: l10n.ofPlanned(formatDuration(metrics.planned, l10n)),
  );
}

MetricTile onTimeTile(BuildContext context, PeriodMetrics metrics) {
  final l10n = AppLocalizations.of(context);
  final rate = metrics.onTimeRate;
  final median = metrics.medianStartDelay;
  return MetricTile(
    key: const Key('metric.onTime'),
    icon: Icons.alarm_on_outlined,
    label: l10n.metricOnTime,
    value: rate == null ? l10n.noValue : formatPercent(context, rate),
    detail: median == null
        ? l10n.noTimedStarts
        : typicalStartLabel(context, median),
  );
}

MetricTile estimateTile(BuildContext context, PeriodMetrics metrics) {
  final l10n = AppLocalizations.of(context);
  final ratio = metrics.estimateRatio;
  return MetricTile(
    key: const Key('metric.estimate'),
    icon: Icons.straighten,
    label: l10n.metricEstimates,
    value: ratio == null ? l10n.noValue : _signedPercent(context, ratio - 1),
    detail: ratio == null
        ? l10n.noMeasurements
        : '${estimateLabel(context, ratio)}\n'
              '${l10n.estimateBasis(metrics.measured)}',
  );
}

String _signedPercent(BuildContext context, double change) {
  final text = formatPercent(context, change.abs());
  if ((change * 100).round() == 0) return text;
  return change > 0 ? '+$text' : '−$text';
}

MetricTile postponedTile(BuildContext context, PeriodMetrics metrics) {
  final l10n = AppLocalizations.of(context);
  return MetricTile(
    key: const Key('metric.postponed'),
    icon: Icons.update,
    label: l10n.metricPostponed,
    value: '${metrics.postponed}',
    detail: l10n.postponementsValue(metrics.postponements),
  );
}
