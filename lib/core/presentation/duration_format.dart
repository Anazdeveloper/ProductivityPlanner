import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// "45 min", "1 h", "1 h 30 min". Seconds are dropped; negative durations
/// show their size (callers word the direction).
String formatDuration(Duration duration, AppLocalizations l10n) {
  final totalMinutes = duration.abs().inMinutes;
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return l10n.durationMinutes(minutes);
  if (minutes == 0) return l10n.durationHours(hours);
  return l10n.durationHoursMinutes(hours, minutes);
}
