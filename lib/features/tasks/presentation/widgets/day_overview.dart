import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/task_visuals.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// "3 of 5 done · 2 h 30 min planned" with a progress bar.
class DayProgress extends StatelessWidget {
  const DayProgress({required this.summary, super.key});

  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = l10n.progressDone(summary.completed, summary.total);
    return Semantics(
      label: '$label. ${l10n.plannedTime(formatDuration(summary.planned, l10n))}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
              Text(
                l10n.plannedTime(formatDuration(summary.planned, l10n)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

/// The one highlighted card on Today: what to do now.
class NextTaskCard extends StatelessWidget {
  const NextTaskCard({
    required this.entry,
    required this.onOpen,
    required this.onComplete,
    this.onStart,
    this.busy = false,
    super.key,
  });

  static const startKey = Key('nextTask.start');

  final AgendaEntry entry;
  final VoidCallback onOpen;
  final VoidCallback onComplete;

  /// Starts the timer; the button is hidden when null.
  final VoidCallback? onStart;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final task = entry.item.task;
    final start = entry.startTime;
    final category = entry.item.category;
    final when = start == null ? l10n.anyTime : formatTime(context, start);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nextTaskLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                task.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '$when · ${formatDuration(entry.item.occurrence.plannedDuration, l10n)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  if (category != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    CategoryDot(color: category.color),
                  ],
                  const SizedBox(width: AppSpacing.sm),
                  StatusLabel(status: entry.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (onStart case final onStartPressed?) ...[
                    Expanded(
                      child: FilledButton.icon(
                        key: startKey,
                        onPressed: busy ? null : onStartPressed,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          entry.item.sessions.isEmpty
                              ? l10n.startAction
                              : l10n.resumeAction,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: onStart == null
                        ? FilledButton.icon(
                            onPressed: busy ? null : onComplete,
                            icon: const Icon(Icons.check),
                            label: Text(l10n.markDone),
                          )
                        : OutlinedButton.icon(
                            onPressed: busy ? null : onComplete,
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
    );
  }
}

/// Shown when a day has nothing planned.
class EmptyDay extends StatelessWidget {
  const EmptyDay({required this.message, required this.onAdd, super.key});

  final String message;
  final VoidCallback onAdd;

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
            Icons.event_available_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(l10n.addTask),
          ),
        ],
      ),
    );
  }
}
