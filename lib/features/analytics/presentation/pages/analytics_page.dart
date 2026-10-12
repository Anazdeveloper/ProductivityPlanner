import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/formatting/analytics_formatters.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/charts/analytics_charts.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/metric_tiles.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/period_lists.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Widest the analytics content grows on tablets.
const double maxAnalyticsContentWidth = 720;

/// Daily, weekly and monthly analytics. Expects an [AnalyticsCubit].
///
/// Every chart has the same numbers in words next to it (tiles, legends,
/// per-bar screen-reader labels), so nothing depends on reading a chart.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({
    required this.onOpenActivity,
    required this.onOpenPlans,
    super.key,
  });

  static const previousKey = Key('analytics.previous');
  static const nextKey = Key('analytics.next');

  final ValueChanged<String> onOpenActivity;

  /// Shown when the plan's history window stops going further back.
  final VoidCallback onOpenPlans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabInsights)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: maxAnalyticsContentWidth,
            ),
            child: BlocBuilder<AnalyticsCubit, AnalyticsState>(
              builder: (context, state) => _AnalyticsBody(
                state: state,
                onOpenActivity: onOpenActivity,
                onOpenPlans: onOpenPlans,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({
    required this.state,
    required this.onOpenActivity,
    required this.onOpenPlans,
  });

  final AnalyticsState state;
  final ValueChanged<String> onOpenActivity;
  final VoidCallback onOpenPlans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<AnalyticsCubit>();
    final report = state.report;
    final earliest = state.access.earliestDate;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SegmentedButton<PeriodKind>(
          segments: [
            ButtonSegment(value: PeriodKind.day, label: Text(l10n.periodDay)),
            ButtonSegment(value: PeriodKind.week, label: Text(l10n.periodWeek)),
            ButtonSegment(
              value: PeriodKind.month,
              label: Text(l10n.periodMonth),
            ),
          ],
          selected: {state.period.kind},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => cubit.selectKind(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        _PeriodNavigator(state: state),
        if (state.historyLimited && earliest != null) ...[
          const SizedBox(height: AppSpacing.sm),
          NoticeBanner(
            text: l10n.historyLimited(earliest.daysUntil(state.today) + 1),
            icon: Icons.lock_outline,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onOpenPlans,
              child: Text(l10n.seePlans),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        ...switch ((state.load, report)) {
          (AnalyticsLoad.failure, _) => [
            FailureBanner(failure: state.loadFailure),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: OutlinedButton(
                onPressed: cubit.retry,
                child: Text(l10n.actionRetry),
              ),
            ),
          ],
          (_, null) => const [
            Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
          (_, final report?) when report.metrics.isEmpty => [
            _EmptyPeriod(kind: state.period.kind),
          ],
          (_, final report?) => _content(context, report, cubit),
        },
      ],
    );
  }

  List<Widget> _content(
    BuildContext context,
    AnalyticsReport report,
    AnalyticsCubit cubit,
  ) {
    final l10n = AppLocalizations.of(context);
    final kind = report.period.kind;
    final metrics = report.metrics;
    return [
      MetricGrid(
        tiles: [
          completionTile(
            context,
            metrics,
            // No comparison with a period the plan's history hides.
            previous: state.access.allows(report.period.previous.end)
                ? report.previous
                : null,
          ),
          trackedTile(context, metrics),
          onTimeTile(context, metrics),
          estimateTile(context, metrics),
          postponedTile(context, metrics),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      if (kind == PeriodKind.day)
        AnalyticsSection(
          title: l10n.planVsActualTitle,
          child: PlanVsActualList(
            executions: report.executions,
            onOpenActivity: onOpenActivity,
          ),
        )
      else ...[
        AnalyticsSection(
          title: l10n.chartOutcomesTitle,
          subtitle: l10n.chartTapHint,
          child: OutcomeChart(
            kind: kind,
            days: report.days,
            onTapDay: cubit.showDay,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AnalyticsSection(
          title: l10n.chartTimeTitle,
          child: TimeChart(
            kind: kind,
            days: report.days,
            onTapDay: cubit.showDay,
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      AnalyticsSection(
        title: l10n.byActivityTitle,
        child: ActivityBreakdownList(
          activities: report.activities,
          onOpenActivity: onOpenActivity,
        ),
      ),
    ];
  }
}

class _PeriodNavigator extends StatelessWidget {
  const _PeriodNavigator({required this.state});

  final AnalyticsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<AnalyticsCubit>();
    final (previous, next, current) = switch (state.period.kind) {
      PeriodKind.day => (l10n.previousDay, l10n.nextDay, l10n.dayToday),
      PeriodKind.week => (l10n.previousWeek, l10n.nextWeek, l10n.thisWeek),
      PeriodKind.month => (l10n.previousMonth, l10n.nextMonth, l10n.thisMonth),
    };
    return Row(
      children: [
        IconButton(
          key: AnalyticsPage.previousKey,
          tooltip: previous,
          onPressed: state.canGoBack ? cubit.previous : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Semantics(
            header: true,
            liveRegion: true,
            child: Text(
              periodLabel(context, state.period, state.today),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (!state.isCurrent)
          TextButton(onPressed: cubit.current, child: Text(current)),
        IconButton(
          key: AnalyticsPage.nextKey,
          tooltip: next,
          onPressed: state.canGoNext ? cubit.next : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _EmptyPeriod extends StatelessWidget {
  const _EmptyPeriod({required this.kind});

  final PeriodKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            switch (kind) {
              PeriodKind.day => l10n.analyticsEmptyDay,
              PeriodKind.week => l10n.analyticsEmptyWeek,
              PeriodKind.month => l10n.analyticsEmptyMonth,
            },
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
