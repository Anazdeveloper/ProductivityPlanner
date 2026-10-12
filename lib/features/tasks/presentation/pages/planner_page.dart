import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/agenda_sections.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/day_overview.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/feedback.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/week_strip.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Week view: pick a day, see and plan its tasks. Expects a
/// [DailyPlannerCubit] in week scope above it.
class PlannerPage extends StatelessWidget {
  const PlannerPage({
    required this.onOpenOccurrence,
    required this.onAddTask,
    super.key,
  });

  final ValueChanged<String> onOpenOccurrence;

  /// Opens the editor for the given day.
  final ValueChanged<LocalDate> onAddTask;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<DailyPlannerCubit, DailyPlannerState>(
      listenWhen: (a, b) => a.actionFailureCount != b.actionFailureCount,
      listener: (context, state) =>
          showFailureSnackBar(context, state.actionFailure),
      builder: (context, state) {
        final cubit = context.read<DailyPlannerCubit>();
        // Adding to a past day plans it for today instead.
        final addDate = maxDate(state.selectedDay, state.today);
        return Scaffold(
          appBar: AppBar(
            title: Text(formatMonthYear(context, state.selectedDay)),
            actions: [
              if (!state.isToday)
                TextButton(
                  onPressed: cubit.goToToday,
                  child: Text(l10n.dayToday),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => onAddTask(addDate),
            icon: const Icon(Icons.add),
            label: Text(l10n.addTask),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: maxTaskContentWidth,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: WeekStrip(
                        weekStart: state.rangeStart,
                        selectedDay: state.selectedDay,
                        today: state.today,
                        summaries: state.rangeSummaries,
                        onSelect: cubit.selectDay,
                        onPreviousWeek: cubit.previousWeek,
                        onNextWeek: cubit.nextWeek,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        0,
                      ),
                      sliver: SliverList.list(
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              formatRelativeDay(
                                context,
                                state.selectedDay,
                                state.today,
                              ),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (state.summary.total > 0) ...[
                            const SizedBox(height: AppSpacing.sm),
                            DayProgress(summary: state.summary),
                          ],
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
                    else if (state.load == PlannerLoad.ready &&
                        state.dayEntries.isEmpty)
                      SliverToBoxAdapter(
                        child: EmptyDay(
                          message: l10n.emptyDay,
                          onAdd: () => onAddTask(addDate),
                        ),
                      )
                    else
                      ...agendaSections(
                        context: context,
                        entries: state.dayEntries,
                        busy: state.busy,
                        onOpen: onOpenOccurrence,
                        onToggleComplete: cubit.toggleComplete,
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 96)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
