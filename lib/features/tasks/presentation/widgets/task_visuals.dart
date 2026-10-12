import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_status_colors.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Colour for a category key, tuned per brightness for contrast on
/// surfaces. Always shown next to the category name, never alone.
Color categoryColor(CategoryColor color, Brightness brightness) {
  final light = brightness == Brightness.light;
  return switch (color) {
    CategoryColor.blue => light ? const Color(0xFF2F5BEA) : const Color(0xFF9DB4FF),
    CategoryColor.purple => light ? const Color(0xFF7B3FD1) : const Color(0xFFCDB0FF),
    CategoryColor.green => light ? const Color(0xFF1E7A46) : const Color(0xFF7FD6A2),
    CategoryColor.orange => light ? const Color(0xFFB45309) : const Color(0xFFFFB873),
    CategoryColor.red => light ? const Color(0xFFC62828) : const Color(0xFFFF9C94),
    CategoryColor.teal => light ? const Color(0xFF00796B) : const Color(0xFF6ED5C7),
    CategoryColor.pink => light ? const Color(0xFFC2185B) : const Color(0xFFFF9EC4),
    CategoryColor.grey => light ? const Color(0xFF5F6368) : const Color(0xFFBDC1C6),
  };
}

/// Small coloured dot for a category.
class CategoryDot extends StatelessWidget {
  const CategoryDot({required this.color, this.size = 8, super.key});

  final CategoryColor color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: categoryColor(color, Theme.of(context).brightness),
      shape: BoxShape.circle,
    ),
  );
}

/// Icon and colour for a derived status. Colour is never the only signal:
/// each status has its own icon and a text label nearby.
({IconData icon, Color color}) statusVisual(
  BuildContext context,
  DerivedStatus status,
) {
  final scheme = Theme.of(context).colorScheme;
  final colors =
      Theme.of(context).extension<AppStatusColors>() ??
      AppStatusColors.fromScheme(scheme);
  return switch (status) {
    DerivedStatus.completed => (icon: Icons.check_circle, color: colors.completed),
    DerivedStatus.inProgress => (icon: Icons.play_circle, color: colors.inProgress),
    DerivedStatus.paused => (icon: Icons.pause_circle, color: colors.inProgress),
    DerivedStatus.skipped => (icon: Icons.redo, color: colors.skipped),
    DerivedStatus.cancelled => (icon: Icons.block, color: colors.skipped),
    DerivedStatus.missed => (icon: Icons.error_outline, color: colors.missed),
    DerivedStatus.overdue => (icon: Icons.schedule, color: colors.missed),
    DerivedStatus.due => (icon: Icons.radio_button_unchecked, color: scheme.primary),
    DerivedStatus.upcoming => (
      icon: Icons.radio_button_unchecked,
      color: scheme.outline,
    ),
  };
}

/// The round "done" control at the start of a row: tap to complete, tap
/// again to reopen. 48 dp target; announces state to screen readers.
class CompletionToggle extends StatelessWidget {
  const CompletionToggle({
    required this.status,
    required this.title,
    required this.onPressed,
    super.key,
  });

  final DerivedStatus status;
  final String title;

  /// Null disables the control (e.g. while saving, or skipped/cancelled).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final visual = statusVisual(context, status);
    final done = status == DerivedStatus.completed;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      onTap: onPressed,
      checked: done,
      label: done ? l10n.reopenTaskNamed(title) : l10n.completeTaskNamed(title),
      excludeSemantics: true,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(visual.icon, color: visual.color),
        tooltip: statusLabel(status, l10n),
      ),
    );
  }
}

/// Compact status label for states that need attention or explanation.
class StatusLabel extends StatelessWidget {
  const StatusLabel({required this.status, super.key});

  final DerivedStatus status;

  @override
  Widget build(BuildContext context) {
    final visual = statusVisual(context, status);
    return Text(
      statusLabel(status, AppLocalizations.of(context)),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: visual.color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
