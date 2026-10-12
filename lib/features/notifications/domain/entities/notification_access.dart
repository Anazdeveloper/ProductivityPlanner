import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_access.freezed.dart';

/// Whether the OS lets the app show notifications.
enum NotificationPermission {
  /// Never asked. Asking shows the system prompt.
  notDetermined,

  /// Allowed (including iOS provisional delivery).
  granted,

  /// Refused; only the system settings can change it.
  denied,
}

/// What the device currently allows, plus the user's in-app switch.
@freezed
abstract class NotificationAccess with _$NotificationAccess {
  const factory NotificationAccess({
    required NotificationPermission permission,

    /// Android 12+: whether reminders can fire at the exact minute. False
    /// means they may arrive a few minutes late. Null where it does not
    /// apply (iOS, older Android).
    bool? exactAlarmsAllowed,

    /// The in-app "Task reminders" switch.
    @Default(true) bool remindersEnabled,
  }) = _NotificationAccess;

  const NotificationAccess._();

  /// Reminders will actually be scheduled.
  bool get remindersActive =>
      remindersEnabled && permission == NotificationPermission.granted;
}
