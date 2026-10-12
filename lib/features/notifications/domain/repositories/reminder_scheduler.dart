import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';

/// The device's local-notification scheduler, limited to this app's
/// reminders. Implementations must schedule at absolute instants (UTC), so
/// a device time-zone change never moves a reminder: each task keeps its
/// own zone and its start is already a fixed instant.
///
/// Throws on platform errors; use cases guard.
abstract interface class ReminderScheduler {
  /// Reminders and snoozes currently pending on the device. Notifications
  /// not created by this app (e.g. displayed pushes) are excluded.
  Future<List<ScheduledReminder>> pending();

  /// Creates or replaces the notification with `request.id`.
  Future<void> schedule(ReminderRequest request);

  Future<void> cancel(int id);

  /// Removes every notification of this app, pending and already shown
  /// (sign-out: nothing about the previous user's tasks may stay on
  /// screen or fire later).
  Future<void> cancelAll();
}
