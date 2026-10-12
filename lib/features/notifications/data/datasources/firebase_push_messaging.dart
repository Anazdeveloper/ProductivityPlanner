import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';

/// Initializes Firebase from the native config files
/// (`google-services.json`, `GoogleService-Info.plist`). Returns false when
/// they are missing or invalid, so the app runs without push instead of
/// crashing (see docs/NOTIFICATIONS_SETUP.md).
Future<bool> initializeFirebase(AppLogger logger) async {
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    return true;
  } on Object catch (error) {
    logger.warning(
      'push disabled: Firebase is not configured',
      context: {'error': error.runtimeType.toString()},
    );
    return false;
  }
}

PushMessage _fromRemote(RemoteMessage message) => PushMessage.fromData(
  message.data,
  title: message.notification?.title,
  body: message.notification?.body,
);

/// [PushMessaging] backed by Firebase Cloud Messaging. Only constructed
/// after [initializeFirebase] succeeded.
final class FirebasePushMessaging implements PushMessaging {
  FirebasePushMessaging({
    required LocalNotificationsClient localNotifications,
    required AppLogger logger,
    FirebaseMessaging? messaging,
  }) : _local = localNotifications,
       _logger = logger,
       _messaging = messaging ?? FirebaseMessaging.instance {
    // iOS shows foreground pushes itself with these options; Android does
    // not, so display messages are shown through the local plugin.
    unawaited(
      _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      ),
    );
  }

  final LocalNotificationsClient _local;
  final AppLogger _logger;
  final FirebaseMessaging _messaging;

  @override
  Future<String?> token() async {
    try {
      return await _messaging.getToken();
    } on Object catch (error) {
      // iOS before APNs registration completes, or Play services missing.
      _logger.warning(
        'push token unavailable',
        context: {'error': error.runtimeType.toString()},
      );
      return null;
    }
  }

  @override
  Stream<String> tokenRefreshes() => _messaging.onTokenRefresh;

  @override
  Stream<PushMessage> foregroundMessages() =>
      FirebaseMessaging.onMessage.asyncMap((remote) async {
        final message = _fromRemote(remote);
        final notification = remote.notification;
        if (_local.isAndroid && notification != null) {
          try {
            await _local.showPush(
            id: pushNotificationId(remote.messageId),
            title: notification.title,
            body: notification.body,
            type: switch (remote.data['type']) {
              final String type => type,
              _ => null,
            },
            route: message.route,
            );
          } on Object catch (error) {
            _logger.warning(
              'foreground push not shown',
              context: {'error': error.runtimeType.toString()},
            );
          }
        }
        return message;
      });

  @override
  Stream<PushMessage> openedMessages() =>
      FirebaseMessaging.onMessageOpenedApp.map(_fromRemote);

  @override
  Future<PushMessage?> launchMessage() async {
    final remote = await _messaging.getInitialMessage();
    return remote == null ? null : _fromRemote(remote);
  }
}

/// [PushMessaging] when Firebase is not configured (mock builds, tests,
/// before setup). Reminders are local and keep working.
final class NoopPushMessaging implements PushMessaging {
  const NoopPushMessaging();

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> tokenRefreshes() => const Stream.empty();

  @override
  Stream<PushMessage> foregroundMessages() => const Stream.empty();

  @override
  Stream<PushMessage> openedMessages() => const Stream.empty();

  @override
  Future<PushMessage?> launchMessage() async => null;
}
