import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/editor/editor_parts.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Repeat settings: frequency, interval, weekdays and when it ends.
class RepeatSection extends StatelessWidget {
  const RepeatSection({
    required this.state,
    required this.cubit,
    required this.startDate,
    this.enabled = true,
    super.key,
  });

  final TaskEditorState state;
  final TaskEditorCubit cubit;

  /// First date of the schedule being edited (limits the end date).
  final LocalDate startDate;

  /// False while saving.
  final bool enabled;

  static const Map<RecurrenceFrequency, int> _maxInterval = {
    RecurrenceFrequency.none: 1,
    RecurrenceFrequency.daily: 365,
    RecurrenceFrequency.weekly: 52,
    RecurrenceFrequency.monthly: 12,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final errors = state.fieldErrors;
    String? errorFor(String field) {
      final code = errors[field];
      return code == null ? null : taskFieldError(field, code, l10n);
    }

    return EditorSection(
      label: l10n.editorRepeat,
      errorText:
          errorFor(TaskFields.interval) ??
          errorFor(TaskFields.until) ??
          errorFor(TaskFields.count),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChoiceChipGroup<RecurrenceFrequency>(
            options: RecurrenceFrequency.values,
            selected: state.frequency,
            enabled: enabled,
            labelOf: (f) => frequencyLabel(f, l10n),
            onSelected: cubit.frequencyChanged,
          ),
          if (state.isRepeating) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: Text(_intervalLabel(l10n))),
                NumberStepper(
                  value: state.interval,
                  min: 1,
                  max: _maxInterval[state.frequency] ?? 1,
                  enabled: enabled,
                  onChanged: cubit.intervalChanged,
                  decrementLabel: l10n.decrease,
                  incrementLabel: l10n.increase,
                ),
              ],
            ),
          ],
          if (state.frequency == RecurrenceFrequency.weekly) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var day = 1; day <= 7; day++)
                  FilterChip(
                    label: Text(formatWeekday(context, day)),
                    selected: state.weekdays.contains(day),
                    onSelected: enabled
                        ? (_) => cubit.weekdayToggled(day)
                        : null,
                  ),
              ],
            ),
          ],
          if (state.isRepeating) ...[
            const SizedBox(height: AppSpacing.md),
            Text(l10n.editorRepeatEnds),
            const SizedBox(height: AppSpacing.sm),
            ChoiceChipGroup<RepeatEnd>(
              options: RepeatEnd.values,
              selected: state.repeatEnd,
              enabled: enabled,
              labelOf: (end) => switch (end) {
                RepeatEnd.never => l10n.repeatEndsNever,
                RepeatEnd.onDate => l10n.repeatEndsOnDate,
                RepeatEnd.afterCount => l10n.repeatEndsAfterCount,
              },
              onSelected: cubit.repeatEndChanged,
            ),
            if (state.repeatEnd == RepeatEnd.onDate) _untilPicker(context),
            if (state.repeatEnd == RepeatEnd.afterCount)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(l10n.repeatTimes(state.count))),
                    NumberStepper(
                      value: state.count,
                      min: 1,
                      max: TaskRules.maxCount,
                      enabled: enabled,
                      onChanged: cubit.countChanged,
                      decrementLabel: l10n.decrease,
                      incrementLabel: l10n.increase,
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _intervalLabel(AppLocalizations l10n) => switch (state.frequency) {
    RecurrenceFrequency.daily => l10n.everyNDaysLabel(state.interval),
    RecurrenceFrequency.weekly => l10n.everyNWeeksLabel(state.interval),
    RecurrenceFrequency.monthly => l10n.everyNMonthsLabel(state.interval),
    RecurrenceFrequency.none => '',
  };

  Widget _untilPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chosen = state.until ?? startDate;
    // The picker requires the initial date inside its range.
    final until = chosen < startDate ? startDate : chosen;
    return PickerTile(
      icon: Icons.event_busy_outlined,
      label: l10n.repeatEndsOnDate,
      value: formatLongDate(context, until),
      onTap: !enabled
          ? null
          : () async {
        final defaultLast = startDate.addDays(365 * 5);
        final picked = await showDatePicker(
          context: context,
          initialDate: until.toDateTimeUtc(),
          firstDate: startDate.toDateTimeUtc(),
          // Never narrower than an existing end date.
          lastDate: maxDate(defaultLast, until).toDateTimeUtc(),
        );
        if (picked != null) cubit.untilChanged(LocalDate.fromDateTime(picked));
      },
    );
  }
}
