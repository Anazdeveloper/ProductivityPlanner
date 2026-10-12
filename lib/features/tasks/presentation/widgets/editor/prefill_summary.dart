import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// What a prefill will put in the editor, one row per field, with "not
/// set" for what was not understood. Used by voice entry's review step
/// (the router passes it in, so voice does not depend on this feature's
/// widgets).
class TaskPrefillSummary extends StatelessWidget {
  const TaskPrefillSummary({
    required this.prefill,
    required this.today,
    this.categoryName,
    super.key,
  });

  final TaskPrefill prefill;
  final LocalDate today;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = prefill.date;
    final time = prefill.time;
    final rule = prefill.recurrence;
    final duration = prefill.duration;
    final when = [
      if (date != null) formatRelativeDay(context, date, today),
      if (time != null)
        formatTime(context, time)
      else if (prefill.anyTime)
        l10n.anyTime,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          icon: Icons.title,
          label: l10n.editorTitleLabel,
          value: prefill.title,
        ),
        _Row(
          icon: Icons.event_outlined,
          label: l10n.prefillWhen,
          value: when.isEmpty ? null : when.join(' · '),
        ),
        _Row(
          icon: Icons.timelapse,
          label: l10n.editorDuration,
          value: duration == null ? null : formatDuration(duration, l10n),
        ),
        _Row(
          icon: Icons.repeat,
          label: l10n.prefillRepeats,
          value: rule == null
              ? null
              : recurrenceSummary(context, rule, startDate: date ?? today),
        ),
        _Row(
          icon: Icons.label_outline,
          label: l10n.prefillCategory,
          value: categoryName,
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = this.value;
    final muted = theme.colorScheme.onSurfaceVariant;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: muted),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 96,
              child: Text(label, style: theme.textTheme.labelLarge),
            ),
            Expanded(
              child: Text(
                value ?? l10n.prefillNotSet,
                style: value == null
                    ? theme.textTheme.bodyMedium?.copyWith(color: muted)
                    : theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
