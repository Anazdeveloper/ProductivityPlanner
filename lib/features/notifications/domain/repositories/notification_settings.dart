import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';

/// OS notification permission. Implementations never prompt unless asked
/// to via [request].
abstract interface class NotificationPermissions {
  Future<NotificationPermission> status();

  /// Shows the system prompt if the permission was never asked; otherwise
  /// returns the current status without a prompt.
  Future<NotificationPermission> request();

  /// Null where exact timing is not a separate permission.
  Future<bool?> exactAlarmsAllowed();

  /// Opens the system screen where the user can allow exact alarms
  /// (Android 12+). Returns the new state, or null where not applicable.
  Future<bool?> requestExactAlarms();

  /// Opens the app's notification settings in the system Settings app.
  Future<void> openSystemSettings();
}

/// This install's notification choices, stored on the device.
abstract interface class ReminderSettings {
  /// The in-app "Task reminders" switch (default on).
  Future<bool> remindersEnabled();

  Future<void> setRemindersEnabled({required bool enabled});

  /// Emits the switch's value now and on every change.
  Stream<bool> watchRemindersEnabled();

  /// Whether the app has already shown the system permission prompt on its
  /// own initiative (it asks once, in context; after that only the user's
  /// explicit "Turn on" asks again).
  Future<bool> permissionPromptShown();

  Future<void> markPermissionPromptShown();

  /// Whether a signed-in session owns the reminders. Cleared at sign-out
  /// before reminders are cancelled, so a background isolate (notification
  /// button, push wake-up) never re-schedules a signed-out user's tasks.
  Future<bool> remindersSessionActive();

  Future<void> setRemindersSessionActive({required bool active});
}
