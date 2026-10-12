import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Monday–Sunday day picker with a per-day "done of total" hint.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.weekStart,
    required this.selectedDay,
    required this.today,
    required this.summaries,
    required this.onSelect,
    required this.onPreviousWeek,
    required this.onNextWeek,
    super.key,
  });

  final LocalDate weekStart;
  final LocalDate selectedDay;
  final LocalDate today;
  final Map<LocalDate, DaySummary> summaries;
  final ValueChanged<LocalDate> onSelect;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          tooltip: l10n.previousWeek,
          icon: const Icon(Icons.chevron_left),
          onPressed: onPreviousWeek,
        ),
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayCell(
              date: weekStart.addDays(i),
              selected: weekStart.addDays(i) == selectedDay,
              isToday: weekStart.addDays(i) == today,
              summary: summaries[weekStart.addDays(i)],
              onTap: () => onSelect(weekStart.addDays(i)),
            ),
          ),
        IconButton(
          tooltip: l10n.nextWeek,
          icon: const Icon(Icons.chevron_right),
          onPressed: onNextWeek,
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selected,
    required this.isToday,
    required this.summary,
    required this.onTap,
  });

  final LocalDate date;
  final bool selected;
  final bool isToday;
  final DaySummary? summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurface;
    final counts = summary;
    final semantics = [
      formatLongDate(context, date),
      if (isToday) l10n.dayToday,
      if (counts != null && counts.total > 0)
        l10n.progressDone(counts.completed, counts.total),
    ].join(', ');

    return Semantics(
      button: true,
      onTap: onTap,
      selected: selected,
      label: semantics,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : null,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !selected
                ? Border.all(color: scheme.primary)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatWeekday(context, date.weekday, narrow: true),
                style: theme.textTheme.labelSmall?.copyWith(color: foreground),
              ),
              Text(
                '${date.day}',
                style: theme.textTheme.titleMedium?.copyWith(color: foreground),
              ),
              Text(
                counts == null || counts.total == 0
                    ? ' '
                    : '${counts.completed}/${counts.total}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
