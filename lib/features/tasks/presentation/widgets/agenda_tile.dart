import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/task_visuals.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// One occurrence in a list: done toggle, title, time, duration, category
/// and, when it matters, its status.
class AgendaTile extends StatelessWidget {
  const AgendaTile({
    required this.entry,
    required this.onTap,
    required this.onToggleComplete,
    this.busy = false,
    super.key,
  });

  final AgendaEntry entry;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final bool busy;

  /// Statuses worth spelling out next to the time.
  static const Set<DerivedStatus> _labelled = {
    DerivedStatus.due,
    DerivedStatus.overdue,
    DerivedStatus.missed,
    DerivedStatus.inProgress,
    DerivedStatus.paused,
    DerivedStatus.skipped,
    DerivedStatus.cancelled,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final task = entry.item.task;
    final occurrence = entry.item.occurrence;
    final category = entry.item.category;
    final resolved = entry.isResolved;
    final canToggle =
        !busy &&
        entry.status != DerivedStatus.skipped &&
        entry.status != DerivedStatus.cancelled;
    final start = entry.startTime;

    final meta = <Widget>[
      Text(start == null ? l10n.anyTime : formatTime(context, start)),
      const _Separator(),
      Text(formatDuration(occurrence.plannedDuration, l10n)),
      if (category != null) ...[
        const _Separator(),
        CategoryDot(color: category.color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: Text(category.name, overflow: TextOverflow.ellipsis)),
      ],
      if (task.isRecurring) ...[
        const SizedBox(width: AppSpacing.sm),
        Icon(Icons.repeat, size: 14, semanticLabel: l10n.repeatingTask),
      ],
      if (occurrence.wasPostponed) ...[
        const SizedBox(width: AppSpacing.xs),
        Icon(Icons.update, size: 14, semanticLabel: l10n.postponedTask),
      ],
    ];

    return ListTile(
      onTap: onTap,
      leading: CompletionToggle(
        status: entry.status,
        title: task.title,
        onPressed: canToggle ? onToggleComplete : null,
      ),
      title: Text(
        task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: resolved
            ? theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                decoration: entry.isDone ? TextDecoration.lineThrough : null,
              )
            : null,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            child: Row(children: meta),
          ),
          if (_labelled.contains(entry.status))
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: StatusLabel(status: entry.status),
            ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    child: Text('·'),
  );
}
