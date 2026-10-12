import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_detail_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/detail/detail_sheets.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/feedback.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/task_visuals.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/focus_timer_feedback.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/timer_widgets.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

enum _MenuAction { cancelOccurrence, endRepeat, delete }

/// One occurrence: what, when, status, its timer, and what can be done.
/// Target of reminder taps (`/occurrences/:id`). Expects a
/// [TaskDetailCubit] and a [FocusTimerBloc] following this occurrence
/// above it: the bloc owns start/pause/resume and timed completion, the
/// cubit everything else.
class OccurrenceDetailPage extends StatelessWidget {
  const OccurrenceDetailPage({
    required this.onEditTask,
    required this.onClose,
    this.onOpenActivity,
    super.key,
  });

  static const completeKey = Key('detail.complete');
  static const doneUnmeasuredKey = Key('detail.doneUnmeasured');
  static const activityKey = Key('detail.activity');

  /// Opens the editor for the task, applying schedule changes from the
  /// given date.
  final void Function(String taskId, LocalDate fromDate) onEditTask;

  /// Leaves the page (after deleting the task).
  final VoidCallback onClose;

  /// Opens the task's analytics (by lineage id); the row is hidden when
  /// null.
  final ValueChanged<String>? onOpenActivity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FocusTimerFeedback(
      child: BlocConsumer<TaskDetailCubit, TaskDetailState>(
      listenWhen: (a, b) =>
          a.actionFailureCount != b.actionFailureCount || a.deleted != b.deleted,
      listener: (context, state) {
        if (state.deleted) {
          onClose();
          return;
        }
        showFailureSnackBar(context, state.actionFailure);
      },
      builder: (context, state) {
        final entry = state.entry;
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (state.status == DetailStatus.ready && entry != null) ...[
                IconButton(
                  tooltip: l10n.editTaskTitle,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: state.busy
                      ? null
                      : () => onEditTask(entry.item.task.id, entry.date),
                ),
                _Menu(entry: entry, enabled: !state.busy),
              ],
            ],
          ),
          body: switch (state.status) {
            DetailStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            DetailStatus.notFound => _Message(text: l10n.occurrenceGone),
            DetailStatus.failure => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: FailureBanner(failure: state.loadFailure),
            ),
            DetailStatus.ready => entry == null
                ? const SizedBox.shrink()
                : _Details(
                    entry: entry,
                    state: state,
                    onOpenActivity: onOpenActivity,
                  ),
          },
          bottomNavigationBar: state.status == DetailStatus.ready && entry != null
              ? _Actions(entry: entry, state: state)
              : null,
        );
      },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.entry,
    required this.state,
    required this.onOpenActivity,
  });

  final AgendaEntry entry;
  final TaskDetailState state;
  final ValueChanged<String>? onOpenActivity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final task = entry.item.task;
    final occurrence = entry.item.occurrence;
    final category = entry.item.category;
    final start = entry.startTime;
    final today = state.today ?? entry.date;
    final note = occurrence.note;
    final notes = task.notes;
    final actual = occurrence.actualDuration;
    final resolvedAt = occurrence.resolvedAt;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxTaskContentWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(task.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  statusVisual(context, entry.status).icon,
                  color: statusVisual(context, entry.status).color,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                StatusLabel(status: entry.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!occurrence.status.isResolved) const _TimerPanel(),
            _InfoRow(
              icon: Icons.event_outlined,
              text: [
                formatRelativeDay(context, entry.date, today),
                if (start != null) formatTime(context, start) else l10n.anyTime,
              ].join(' · '),
            ),
            _InfoRow(
              icon: Icons.timelapse,
              text: l10n.plannedTime(
                formatDuration(occurrence.plannedDuration, l10n),
              ),
            ),
            if (task.isRecurring)
              _InfoRow(
                icon: Icons.repeat,
                text: recurrenceSummary(
                  context,
                  task.schedule.rule,
                  startDate: task.schedule.startDate,
                ),
              ),
            if (category != null)
              _InfoRow(
                leading: CategoryDot(color: category.color, size: 12),
                text: category.name,
              ),
            _InfoRow(
              icon: Icons.flag_outlined,
              text: priorityLabel(task.priority, l10n),
            ),
            if (occurrence.wasPostponed)
              _InfoRow(
                icon: Icons.update,
                text: l10n.postponedTimes(occurrence.postponeCount),
              ),
            if (occurrence.status == OccurrenceStatus.completed &&
                resolvedAt != null)
              _InfoRow(
                icon: Icons.check_circle_outline,
                text: actual == null
                    ? l10n.completedUnmeasured
                    : l10n.completedTook(formatDuration(actual, l10n)),
              ),
            if (occurrence.status == OccurrenceStatus.skipped &&
                occurrence.skipReason != null)
              _InfoRow(
                icon: Icons.redo,
                text: skipReasonLabel(
                  occurrence.skipReason ?? SkipReason.other,
                  l10n,
                ),
              ),
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(notes, style: theme.textTheme.bodyMedium),
            ],
            const Divider(height: AppSpacing.xl),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: Text(l10n.noteTitle),
              subtitle: Text(
                note == null || note.isEmpty ? l10n.noteEmpty : note,
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: state.busy
                  ? null
                  : () async {
                      final cubit = context.read<TaskDetailCubit>();
                      final text = await showNoteDialog(
                        context,
                        initial: note,
                      );
                      if (text != null) await cubit.saveNote(text);
                    },
            ),
            if (onOpenActivity case final openActivity?)
              ListTile(
                key: OccurrenceDetailPage.activityKey,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.insights_outlined),
                title: Text(l10n.activityInsights),
                subtitle: Text(l10n.activityInsightsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openActivity(task.lineageId),
              ),
          ],
        ),
      ),
    );
  }
}

/// The live timer of an occurrence that has been started.
class _TimerPanel extends StatelessWidget {
  const _TimerPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusTimerBloc, FocusTimerState>(
      builder: (context, focus) {
        final timer = focus.timer;
        if (timer == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: ElapsedText(timer: timer)),
                  const SizedBox(height: AppSpacing.sm),
                  PlanProgress(timer: timer),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.text, this.icon, this.leading});

  final String text;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Center(
              child:
                  leading ??
                  Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.entry, required this.state});

  final AgendaEntry entry;
  final TaskDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TaskDetailCubit>();
    final occurrence = entry.item.occurrence;

    return BlocBuilder<FocusTimerBloc, FocusTimerState>(
      builder: (context, focus) {
        final timerBloc = context.read<FocusTimerBloc>();
        final busy = state.busy || focus.busy;
        final timer = focus.timer;
        // The timer's copy is the freshest; fall back while it loads.
        final current = focus.item?.occurrence ?? occurrence;
        final inProgress = current.status == OccurrenceStatus.inProgress;
        final timerReady = focus.load == FocusLoad.ready;

        final Widget content;
        if (current.status.isResolved) {
          content = FilledButton.tonalIcon(
            onPressed: busy ? null : cubit.reopen,
            icon: const Icon(Icons.undo),
            label: Text(l10n.reopen),
          );
        } else {
          final doneWithDuration = OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    final took = await showActualDurationDialog(
                      context,
                      planned: timer?.tracked ?? occurrence.plannedDuration,
                    );
                    if (took != null) {
                      await cubit.complete(actualDuration: took);
                    }
                  },
            child: Text(l10n.doneWithDuration),
          );
          content = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TimerToggleButton(
                      running: focus.running,
                      started: inProgress,
                      enabled: !busy && timerReady,
                      onStart: () =>
                          timerBloc.add(const FocusTimerStartPressed()),
                      onPause: () =>
                          timerBloc.add(const FocusTimerPausePressed()),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    // Started: Done uses the tracked time (with a sanity
                    // check). Not started: done without a measurement.
                    child: inProgress
                        ? FilledButton.tonalIcon(
                            key: OccurrenceDetailPage.completeKey,
                            onPressed: busy || !timerReady
                                ? null
                                : () => timerBloc.add(
                                    const FocusTimerCompletePressed(),
                                  ),
                            icon: const Icon(Icons.check),
                            label: Text(l10n.markDone),
                          )
                        : FilledButton.tonalIcon(
                            key: OccurrenceDetailPage.doneUnmeasuredKey,
                            onPressed: busy ? null : cubit.complete,
                            icon: const Icon(Icons.check),
                            label: Text(l10n.markDone),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: doneWithDuration),
                  if (!inProgress) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => _postpone(context, cubit),
                        child: Text(l10n.postpone),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final reason = await showSkipSheet(context);
                                if (reason != null) await cubit.skip(reason);
                              },
                        child: Text(l10n.skip),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: content,
          ),
        );
      },
    );
  }

  Future<void> _postpone(BuildContext context, TaskDetailCubit cubit) async {
    final today = state.today ?? entry.date;
    final choice = await showPostponeSheet(
      context,
      canLaterToday: state.canPostponeLaterToday,
      today: today,
      hasTime: entry.startTime != null,
    );
    switch (choice) {
      case PostponeLaterToday():
        await cubit.postponeLaterToday();
      case PostponeTomorrow():
        await cubit.postponeTomorrow();
      case PostponeToSlot(:final date, :final time):
        await cubit.postponeTo(date, time);
      case null:
        break;
    }
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.entry, required this.enabled});

  final AgendaEntry entry;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<TaskDetailCubit>();
    final task = entry.item.task;
    return PopupMenuButton<_MenuAction>(
      enabled: enabled,
      tooltip: l10n.moreActions,
      onSelected: (action) async {
        switch (action) {
          case _MenuAction.cancelOccurrence:
            await cubit.cancelOccurrence();
          case _MenuAction.endRepeat:
            final confirmed = await confirmAction(
              context,
              title: l10n.endRepeatTitle,
              message: l10n.endRepeatMessage,
              confirmLabel: l10n.endRepeat,
            );
            if (confirmed) await cubit.endRepeat();
          case _MenuAction.delete:
            final confirmed = await confirmAction(
              context,
              title: l10n.deleteTaskTitle,
              message: task.isRecurring
                  ? l10n.deleteRepeatingTaskMessage
                  : l10n.deleteTaskMessage,
              confirmLabel: l10n.deleteTask,
            );
            if (confirmed) await cubit.deleteTask();
        }
      },
      itemBuilder: (_) => [
        if (!entry.isResolved)
          PopupMenuItem(
            value: _MenuAction.cancelOccurrence,
            child: Text(l10n.cancelOccurrence),
          ),
        if (task.isRecurring && task.endedOn == null)
          PopupMenuItem(
            value: _MenuAction.endRepeat,
            child: Text(l10n.endRepeat),
          ),
        PopupMenuItem(
          value: _MenuAction.delete,
          child: Text(l10n.deleteTask),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
