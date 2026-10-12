import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';
import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';

/// Remote push (FCM). An implementation exists that does nothing, used when
/// Firebase is not configured (mock builds, CI, a fresh checkout), so the
/// rest of the app never checks whether push is available.
abstract interface class PushMessaging {
  /// The current registration token, or null if push is unavailable.
  Future<String?> token();

  Stream<String> tokenRefreshes();

  /// Messages received while the app is in the foreground.
  Stream<PushMessage> foregroundMessages();

  /// Pushes the user tapped while the app was in the background.
  Stream<PushMessage> openedMessages();

  /// The push that launched the app from terminated, if any. Consumed once.
  Future<PushMessage?> launchMessage();
}

/// This install's record on the server (`PUT devices/{id}`).
abstract interface class DeviceRegistrationRepository {
  Future<Result<Unit>> register({
    required String? pushToken,
    required bool remindersEnabled,
  });
}

/// `me/notification-preferences`.
abstract interface class NotificationPreferencesRepository {
  Future<Result<NotificationPreferences>> load();

  Future<Result<NotificationPreferences>> save(
    NotificationPreferences preferences,
  );
}
