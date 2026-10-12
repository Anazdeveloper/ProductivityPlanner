import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/agenda_sections.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/day_overview.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/feedback.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/quick_add_field.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/active_work_card.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/focus_timer_feedback.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Home screen: today's date, progress, what is being worked on (live
/// timer), the next task, quick add and the day's list split into to-do and
/// done. Expects a [DailyPlannerCubit] in day scope and a [FocusTimerBloc]
/// following the active work above it.
class TodayPage extends StatelessWidget {
  const TodayPage({
    required this.onOpenOccurrence,
    required this.onAddTask,
    this.banner,
    this.onVoiceAdd,
    this.onOpenPlans,
    super.key,
  });

  final ValueChanged<String> onOpenOccurrence;

  /// Optional notice above the day (e.g. "reminders are off"), supplied by
  /// the router so this feature does not depend on another's widgets.
  final Widget? banner;

  /// Opens the full editor, optionally with a title from quick add.
  final void Function({String? title}) onAddTask;

  /// Adds a task by voice; the microphone is hidden when null.
  final VoidCallback? onVoiceAdd;

  /// Opens the plans screen (offered when a plan limit stops an action).
  final VoidCallback? onOpenPlans;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<DailyPlannerCubit, DailyPlannerState>(
      listenWhen: (a, b) => a.actionFailureCount != b.actionFailureCount,
      listener: (context, state) => showFailureSnackBar(
        context,
        state.actionFailure,
        onOpenPlans: onOpenPlans,
      ),
      child: FocusTimerFeedback(
        child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: onAddTask,
          icon: const Icon(Icons.add),
          label: Text(l10n.addTask),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxTaskContentWidth),
              child: BlocBuilder<DailyPlannerCubit, DailyPlannerState>(
                builder: (context, state) => _TodayBody(
                  state: state,
                  banner: banner,
                  onOpenOccurrence: onOpenOccurrence,
                  onAddTask: onAddTask,
                  onVoiceAdd: onVoiceAdd,
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _TodayBody extends StatelessWidget {
  const _TodayBody({
    required this.state,
    required this.banner,
    required this.onOpenOccurrence,
    required this.onAddTask,
    required this.onVoiceAdd,
  });

  final DailyPlannerState state;
  final Widget? banner;
  final ValueChanged<String> onOpenOccurrence;
  final void Function({String? title}) onAddTask;
  final VoidCallback? onVoiceAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<DailyPlannerCubit>();
    final next = state.summary.next;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          sliver: SliverList.list(
            children: [
              if (banner case final b?) b,
              Semantics(
                header: true,
                child: Text(
                  formatLongDate(context, state.today),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (state.summary.total > 0) ...[
                DayProgress(summary: state.summary),
                const SizedBox(height: AppSpacing.md),
              ],
              ActiveWorkCard(onOpen: onOpenOccurrence),
              if (next != null)
                BlocSelector<
                  FocusTimerBloc,
                  FocusTimerState,
                  ({String? activeId, bool focusBusy})
                >(
                  selector: (focus) => (
                    activeId: focus.item?.occurrence.id,
                    focusBusy: focus.busy,
                  ),
                  builder: (context, focus) {
                    final (:activeId, :focusBusy) = focus;
                    // The working-on card already shows it.
                    if (activeId == next.occurrenceId) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: NextTaskCard(
                        entry: next,
                        busy:
                            focusBusy ||
                            state.busy.contains(next.occurrenceId),
                        onOpen: () => onOpenOccurrence(next.occurrenceId),
                        onComplete: () =>
                            cubit.toggleComplete(next.occurrenceId),
                        onStart: () => context.read<FocusTimerBloc>().add(
                          FocusTimerStartPressed(
                            occurrenceId: next.occurrenceId,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              QuickAddField(
                onSubmit: cubit.quickAdd,
                onMoreOptions: (title) =>
                    onAddTask(title: title.isEmpty ? null : title),
                onVoice: onVoiceAdd,
              ),
              if (state.loadFailure != null) ...[
                const SizedBox(height: AppSpacing.md),
                FailureBanner(failure: state.loadFailure),
              ],
            ],
          ),
        ),
        if (state.load == PlannerLoad.loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (state.load == PlannerLoad.ready && state.dayEntries.isEmpty)
          SliverToBoxAdapter(
            child: EmptyDay(message: l10n.emptyToday, onAdd: onAddTask),
          )
        else
          ...agendaSections(
            context: context,
            entries: state.dayEntries,
            busy: state.busy,
            onOpen: onOpenOccurrence,
            onToggleComplete: cubit.toggleComplete,
          ),
        // Room for the floating button.
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}
