import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';

/// What a scheduled local notification is for.
enum ReminderKind {
  /// "Starts in 5 minutes", derived from a task's reminder offsets.
  reminder,

  /// The user tapped "Snooze" on a reminder.
  snooze,
}

/// A local notification the app wants to exist.
///
/// Holds facts, not text: the data layer formats the localized title and
/// body (it may run in a background isolate without a widget tree).
@freezed
abstract class ReminderRequest with _$ReminderRequest {
  const factory ReminderRequest({
    /// Platform notification id (31-bit, stable for the same reminder).
    required int id,
    required String occurrenceId,
    required ReminderKind kind,

    /// When to show it (UTC).
    required DateTime fireAt,
    required String taskTitle,

    /// The occurrence's start (UTC), shown as a wall time in `timeZone`.
    required DateTime startAt,
    required String timeZone,
  }) = _ReminderRequest;

  const ReminderRequest._();

  /// Changes whenever anything the user would see or the timing changes,
  /// so the reconciler can tell an outdated scheduled notification from a
  /// current one without reading its text back.
  String get fingerprint => stableHash(
    '${kind.name}|${fireAt.toUtc().toIso8601String()}|'
    '${startAt.toUtc().toIso8601String()}|$timeZone|$taskTitle',
  ).toRadixString(36);
}

/// A notification this app has scheduled and the platform still holds.
@freezed
abstract class ScheduledReminder with _$ScheduledReminder {
  const factory ScheduledReminder({
    required int id,
    required String occurrenceId,
    required ReminderKind kind,
    required String fingerprint,
  }) = _ScheduledReminder;
}

/// 32-bit FNV-1a, masked to 31 bits (Android notification ids are signed
/// ints; negative ids are legal but confusing in logs).
///
/// Deterministic across runs, isolates and devices, unlike
/// `String.hashCode`.
int stableHash(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}

/// The notification id of a reminder [offset] before [occurrenceId]'s
/// start, or of its snooze. With at most ~50 pending, a collision between
/// two live reminders is vanishingly unlikely; if it happens the later
/// schedule replaces the earlier one (one missed reminder, no crash).
int reminderNotificationId(
  String occurrenceId,
  ReminderKind kind, {
  Duration offset = Duration.zero,
}) => stableHash('${kind.name}|$occurrenceId|${offset.inSeconds}');
