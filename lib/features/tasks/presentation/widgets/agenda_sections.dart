import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/agenda_tile.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// The day's list as slivers: "To do" first, then "Done" (completed,
/// skipped, cancelled). The section headers double as the pending/
/// completed summary.
List<Widget> agendaSections({
  required BuildContext context,
  required List<AgendaEntry> entries,
  required Set<String> busy,
  required ValueChanged<String> onOpen,
  required ValueChanged<String> onToggleComplete,
}) {
  final l10n = AppLocalizations.of(context);
  final pending = [for (final e in entries) if (!e.isResolved) e];
  final finished = [for (final e in entries) if (e.isResolved) e];

  Widget tile(AgendaEntry entry) => AgendaTile(
    key: ValueKey(entry.occurrenceId),
    entry: entry,
    busy: busy.contains(entry.occurrenceId),
    onTap: () => onOpen(entry.occurrenceId),
    onToggleComplete: () => onToggleComplete(entry.occurrenceId),
  );

  return [
    if (pending.isNotEmpty) ...[
      _header(context, l10n.sectionToDo(pending.length)),
      SliverList.list(children: [for (final e in pending) tile(e)]),
    ],
    if (finished.isNotEmpty) ...[
      _header(context, l10n.sectionDone(finished.length)),
      SliverList.list(children: [for (final e in finished) tile(e)]),
    ],
  ];
}

Widget _header(BuildContext context, String text) => SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.md,
      AppSpacing.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  ),
);
