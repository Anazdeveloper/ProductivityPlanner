import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/timer_widgets.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Today's "Working on" card: the running (or last paused) task with its
/// live timer, Pause/Resume and Done. Renders nothing when nothing is in
/// progress. Expects a [FocusTimerBloc] following [ActiveWorkTarget].
class ActiveWorkCard extends StatelessWidget {
  const ActiveWorkCard({required this.onOpen, super.key});

  static const doneKey = Key('activeWork.done');

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusTimerBloc, FocusTimerState>(
      builder: (context, state) {
        final item = state.item;
        final timer = state.timer;
        if (item == null || timer == null) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final bloc = context.read<FocusTimerBloc>();
        final onColor = theme.colorScheme.onPrimaryContainer;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Card(
            color: theme.colorScheme.primaryContainer,
            child: InkWell(
              onTap: () => onOpen(item.occurrence.id),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          timer.running ? Icons.timer_outlined : Icons.pause,
                          size: 18,
                          color: onColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          timer.running
                              ? l10n.timerRunningLabel
                              : l10n.timerPausedLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: onColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: onColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElapsedText(
                      timer: timer,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: onColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PlanProgress(timer: timer),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TimerToggleButton(
                            running: timer.running,
                            started: true,
                            enabled: !state.busy,
                            onStart: () =>
                                bloc.add(const FocusTimerStartPressed()),
                            onPause: () =>
                                bloc.add(const FocusTimerPausePressed()),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            key: doneKey,
                            onPressed: state.busy
                                ? null
                                : () => bloc.add(
                                    const FocusTimerCompletePressed(),
                                  ),
                            icon: const Icon(Icons.check),
                            label: Text(l10n.markDone),
                          ),
                        ),
                      ],
                    ),
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
