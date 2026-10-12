import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:url_launcher/url_launcher.dart';

/// [NotificationPermissions] via `flutter_local_notifications`.
///
/// Neither platform API says "never asked" directly: a disabled state means
/// "denied" only once the app has asked, which is recorded in `app_meta`.
/// (Android below 13 has no prompt; notifications are on unless the user
/// turned them off, which then reads as denied after the first request.)
final class LocalNotificationPermissions implements NotificationPermissions {
  const LocalNotificationPermissions({
    required LocalNotificationsClient client,
    required AppMetaStore meta,
  }) : _client = client,
       _meta = meta;

  final LocalNotificationsClient _client;
  final AppMetaStore _meta;

  AndroidFlutterLocalNotificationsPlugin? get _android => _client.plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _client.plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<NotificationPermission> status() async {
    await _client.initialize();
    if (await _enabled()) return NotificationPermission.granted;
    final asked = await _meta.read(AppMetaKeys.notificationPermissionAsked);
    return asked == null
        ? NotificationPermission.notDetermined
        : NotificationPermission.denied;
  }

  @override
  Future<NotificationPermission> request() async {
    await _client.initialize();
    if (_client.isAndroid) {
      await _android?.requestNotificationsPermission();
    } else if (_client.isIos) {
      await _ios?.requestPermissions(alert: true, sound: true, badge: true);
    }
    await _meta.write(AppMetaKeys.notificationPermissionAsked, 'true');
    return await status();
  }

  @override
  Future<bool?> exactAlarmsAllowed() async {
    if (!_client.isAndroid) return null;
    await _client.initialize();
    return await _android?.canScheduleExactNotifications();
  }

  @override
  Future<bool?> requestExactAlarms() async {
    if (!_client.isAndroid) return null;
    await _client.initialize();
    await _android?.requestExactAlarmsPermission();
    return await _android?.canScheduleExactNotifications();
  }

  @override
Future<void> openSystemSettings() async {
  await _client.initialize();
  if (_client.isIos) {
    // UIApplication.openSettingsURLString: the app's page in Settings,
    // which includes its Notifications switch.
    await launchUrl(Uri.parse('app-settings:'));
  } else if (_client.isAndroid) {
    // Older plugin versions cannot open Android's notification settings;
    // asking again shows the system prompt if it is still allowed.
    await _android?.requestNotificationsPermission();
  }
}

  Future<bool> _enabled() async {
    if (_client.isAndroid) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    if (_client.isIos) {
      final options = await _ios?.checkPermissions();
      return options?.isEnabled ?? false;
    }
    return false;
  }
}
