import 'package:flutter/material.dart';

/// Colours for occurrence states. Always paired with an icon or label in the
/// UI so status is never conveyed by colour alone (accessibility).
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.completed,
    required this.inProgress,
    required this.skipped,
    required this.missed,
  });

  factory AppStatusColors.fromScheme(ColorScheme scheme) => AppStatusColors(
    completed: scheme.brightness == Brightness.light
        ? const Color(0xFF1B7F4B)
        : const Color(0xFF6FD39B),
    inProgress: scheme.primary,
    skipped: scheme.outline,
    missed: scheme.error,
  );

  final Color completed;
  final Color inProgress;
  final Color skipped;
  final Color missed;

  @override
  AppStatusColors copyWith({
    Color? completed,
    Color? inProgress,
    Color? skipped,
    Color? missed,
  }) => AppStatusColors(
    completed: completed ?? this.completed,
    inProgress: inProgress ?? this.inProgress,
    skipped: skipped ?? this.skipped,
    missed: missed ?? this.missed,
  );

  @override
  AppStatusColors lerp(covariant AppStatusColors? other, double t) {
    if (other == null) return this;
    return AppStatusColors(
      completed: Color.lerp(completed, other.completed, t) ?? completed,
      inProgress: Color.lerp(inProgress, other.inProgress, t) ?? inProgress,
      skipped: Color.lerp(skipped, other.skipped, t) ?? skipped,
      missed: Color.lerp(missed, other.missed, t) ?? missed,
    );
  }
}
