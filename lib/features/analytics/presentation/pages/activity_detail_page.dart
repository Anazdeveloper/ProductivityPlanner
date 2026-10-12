import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/duration_format.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/activity_analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/formatting/analytics_formatters.dart';
import 'package:productivity_planner/features/analytics/presentation/pages/analytics_page.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/charts/analytics_charts.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/metric_tiles.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/period_lists.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Task-specific analytics: one activity across schedule changes (keyed by
/// lineage), with streaks, plan-vs-actual history and a learned duration.
/// Expects an [ActivityAnalyticsCubit].
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({required this.onOpenPlans, super.key});

  static const applyKey = Key('activity.applySuggestion');

  final VoidCallback onOpenPlans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<ActivityAnalyticsCubit, ActivityAnalyticsState>(
          listenWhen: (a, b) => a.appliedCount != b.appliedCount,
          listener: (context, _) => _snack(context, l10n.suggestionApplied),
        ),
        BlocListener<ActivityAnalyticsCubit, ActivityAnalyticsState>(
          listenWhen: (a, b) => a.failureCount != b.failureCount,
          listener: (context, state) => _snackFailure(context, state.failure),
        ),
      ],
      child: BlocBuilder<ActivityAnalyticsCubit, ActivityAnalyticsState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text(state.stats?.title ?? l10n.activityTitle)),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: maxAnalyticsContentWidth,
                ),
                child: _ActivityBody(state: state, onOpenPlans: onOpenPlans),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  static void _snackFailure(BuildContext context, Failure? failure) {
    if (failure == null) return;
    final text = failure.message(AppLocalizations.of(context));
    if (text.isNotEmpty) _snack(context, text);
  }
}

class _ActivityBody extends StatelessWidget {
  const _ActivityBody({required this.state, required this.onOpenPlans});

  final ActivityAnalyticsState state;
  final VoidCallback onOpenPlans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stats = state.stats;
    if (state.load == ActivityLoad.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.load == ActivityLoad.failure) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: FailureBanner(failure: state.loadFailure),
      );
    }
    if (state.load == ActivityLoad.notFound || stats == null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          l10n.activityNotFound,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }
    final from = state.from;
    final metrics = stats.metrics;
    final suggestion = state.suggestion;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (from != null)
          Text(
            l10n.activitySince(formatShortDay(context, from)),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        MetricGrid(
          tiles: [
            completionTile(context, metrics),
            MetricTile(
              key: const Key('metric.streak'),
              icon: Icons.local_fire_department_outlined,
              label: l10n.streakCurrent,
              value: l10n.streakValue(stats.currentStreak),
              detail: l10n.streakBest(stats.bestStreak),
            ),
            onTimeTile(context, metrics),
            estimateTile(context, metrics),
            trackedTile(context, metrics),
            postponedTile(context, metrics),
          ],
        ),
        if (suggestion != null) ...[
          const SizedBox(height: AppSpacing.md),
          _SuggestionCard(suggestion: suggestion, applying: state.applying),
        ] else if (state.suggestionLocked) ...[
          const SizedBox(height: AppSpacing.md),
          NoticeBanner(
            text: l10n.suggestionLocked,
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
        if (stats.history.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AnalyticsSection(
            title: l10n.historyChartTitle,
            subtitle: l10n.historyChartSubtitle(stats.history.length),
            child: ActivityHistoryChart(history: stats.history),
          ),
        ],
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.applying});

  final DurationSuggestion suggestion;
  final bool applying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final suggested = formatDuration(suggestion.suggested, l10n);
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.suggestionTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.suggestionBody(
                suggestion.basedOn,
                suggested,
                formatDuration(suggestion.current, l10n),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              key: ActivityDetailPage.applyKey,
              onPressed: applying
                  ? null
                  : context.read<ActivityAnalyticsCubit>().applySuggestion,
              child: Text(l10n.suggestionApply(suggested)),
            ),
          ],
        ),
      ),
    );
  }
}
