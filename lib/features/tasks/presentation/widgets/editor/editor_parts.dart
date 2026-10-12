import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';

/// A labelled block of the task form.
class EditorSection extends StatelessWidget {
  const EditorSection({
    required this.label,
    required this.child,
    this.errorText,
    super.key,
  });

  final String label;
  final Widget child;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = errorText;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Single-choice chips that wrap onto several lines.
class ChoiceChipGroup<T> extends StatelessWidget {
  const ChoiceChipGroup({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.enabled = true,
    this.avatarOf,
    super.key,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final bool enabled;
  final Widget? Function(T)? avatarOf;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: [
      for (final option in options)
        ChoiceChip(
          label: Text(labelOf(option)),
          avatar: avatarOf?.call(option),
          selected: option == selected,
          onSelected: enabled ? (_) => onSelected(option) : null,
        ),
    ],
  );
}

/// "− 2 +" stepper for small whole numbers.
class NumberStepper extends StatelessWidget {
  const NumberStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.decrementLabel,
    required this.incrementLabel,
    this.enabled = true,
    super.key,
  });

  final int value;
  final bool enabled;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String decrementLabel;
  final String incrementLabel;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.outlined(
        tooltip: decrementLabel,
        onPressed: enabled && value > min ? () => onChanged(value - 1) : null,
        icon: const Icon(Icons.remove),
      ),
      SizedBox(
        width: 48,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      IconButton.outlined(
        tooltip: incrementLabel,
        onPressed: enabled && value < max ? () => onChanged(value + 1) : null,
        icon: const Icon(Icons.add),
      ),
    ],
  );
}

/// A tappable row showing a picked value (date, time).
class PickerTile extends StatelessWidget {
  const PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(value),
    subtitle: Text(label),
    trailing: trailing,
    onTap: onTap,
  );
}
