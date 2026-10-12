import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/app_status_colors.dart';
import 'package:productivity_planner/core/presentation/duration_format.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/presentation/formatting/analytics_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// A titled section card on the analytics screens.
class AnalyticsSection extends StatelessWidget {
  const AnalyticsSection({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

/// The Day view: each occurrence's planned time against the time it took,
/// with its outcome and how late it started.
class PlanVsActualList extends StatelessWidget {
  const PlanVsActualList({
    required this.executions,
    required this.onOpenActivity,
    super.key,
  });

  final List<ExecutionSummary> executions;
  final ValueChanged<String> onOpenActivity;

  @override
  Widget build(BuildContext context) {
    var longest = Duration.zero;
    for (final e in executions) {
      if (e.record.planned > longest) longest = e.record.planned;
      final measured = e.measured;
      if (measured != null && measured > longest) longest = measured;
    }
    return Column(
      children: [
        for (final execution in executions)
          _PlanVsActualRow(
            execution: execution,
            longest: longest,
            onTap: () => onOpenActivity(execution.record.lineageId),
          ),
      ],
    );
  }
}

class _PlanVsActualRow extends StatelessWidget {
  const _PlanVsActualRow({
    required this.execution,
    required this.longest,
    required this.onTap,
  });

  final ExecutionSummary execution;
  final Duration longest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors =
        theme.extension<AppStatusColors>() ??
        AppStatusColors.fromScheme(theme.colorScheme);
    final record = execution.record;
    final measured = execution.measured;
    final planned = formatDuration(record.planned, l10n);
    final actual = measured == null
        ? l10n.notMeasured
        : formatDuration(measured, l10n);
    final delay = record.startDelay;
    final color = switch (execution.outcome) {
      ExecutionOutcome.completed => colors.completed,
      ExecutionOutcome.skipped => colors.skipped,
      ExecutionOutcome.missed => colors.missed,
      ExecutionOutcome.open => colors.inProgress,
    };
    final details = [
      outcomeLabel(execution.outcome, l10n),
      l10n.plannedVsActual(planned, actual),
      if (delay != null) startDelayLabel(context, delay),
    ].join(' · ');

    double share(Duration value) => longest == Duration.zero
        ? 0
        : (value.inSeconds / longest.inSeconds).clamp(0, 1).toDouble();

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.title,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Track(
                      share: share(record.planned),
                      color: theme.colorScheme.outline,
                      outlined: true,
                    ),
                    const SizedBox(height: 3),
                    _Track(
                      share: share(measured ?? Duration.zero),
                      color: color,
                      outlined: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.share,
    required this.color,
    required this.outlined,
  });

  final double share;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: share <= 0 ? 0.002 : share,
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: outlined ? null : color,
          border: outlined ? Border.all(color: color, width: 1.5) : null,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// "By activity": each activity's completions and time in the period.
class ActivityBreakdownList extends StatelessWidget {
  const ActivityBreakdownList({
    required this.activities,
    required this.onOpenActivity,
    super.key,
  });

  final List<ActivityBreakdown> activities;
  final ValueChanged<String> onOpenActivity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final activity in activities)
          ListTile(
            key: Key('activity.${activity.lineageId}'),
            contentPadding: EdgeInsets.zero,
            title: Text(
              activity.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              l10n.activityRowSubtitle(
                activity.metrics.completed,
                activity.metrics.counted,
                formatDuration(activity.metrics.tracked, l10n),
              ),
            ),
            trailing: Text(
              switch (activity.metrics.completionRate) {
                final rate? => formatPercent(context, rate),
                null => l10n.noValue,
              },
              style: Theme.of(context).textTheme.titleSmall,
            ),
            onTap: () => onOpenActivity(activity.lineageId),
          ),
      ],
    );
  }
}
