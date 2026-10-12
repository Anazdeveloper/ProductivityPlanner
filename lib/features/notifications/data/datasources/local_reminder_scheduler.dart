import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:productivity_planner/core/timezone/tz_instant.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/data/datasources/notification_texts.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_payload.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/reminder_scheduler.dart';

/// [ReminderScheduler] on top of `flutter_local_notifications`.
///
/// - Instants are scheduled in UTC, so a device time-zone change does not
///   move them.
/// - Android uses exact alarms when the user allows them, otherwise
///   inexact-while-idle (may be a few minutes late; the settings screen
///   offers to allow exact timing).
/// - The plugin reschedules pending alarms after a reboot or app update
///   (boot receiver in the Android manifest).
final class LocalReminderScheduler implements ReminderScheduler {
  const LocalReminderScheduler({
    required LocalNotificationsClient client,
    required NotificationTexts texts,
  }) : _client = client,
       _texts = texts;

  final LocalNotificationsClient _client;
  final NotificationTexts _texts;

  /// A reminder armed in a different mode than the current one (e.g.
  /// inexact before the user allowed exact alarms) reports a fingerprint
  /// that cannot match, so the reconciler re-arms it.
  @override
  Future<List<ScheduledReminder>> pending() async {
    await _client.initialize();
    final requests = await _client.plugin.pendingNotificationRequests();
    final mode = _modeTag(await _androidMode());
    return [
      for (final request in requests)
        if (NotificationPayload.decode(request.payload)
            case ReminderPayload(
              :final occurrenceId,
              :final kind,
              :final fingerprint,
              :final scheduleMode,
            ))
          ScheduledReminder(
            id: request.id,
            occurrenceId: occurrenceId,
            kind: kind,
            fingerprint: scheduleMode == mode ? fingerprint : '$fingerprint~',
          ),
    ];
  }

  @override
  Future<void> schedule(ReminderRequest request) async {
    await _client.initialize();
    final mode = await _androidMode();
    await _client.plugin.zonedSchedule(
      id: request.id,
      scheduledDate: tzInstant(request.fireAt),
      notificationDetails: _client.reminderDetails(),
      androidScheduleMode: mode,
      title: _texts.title(request),
      body: _texts.body(request),
      payload: ReminderPayload.of(
        request,
        scheduleMode: _modeTag(mode),
      ).encode(),
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _client.initialize();
    await _client.plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _client.initialize();
    await _client.plugin.cancelAll();
  }

  static String _modeTag(AndroidScheduleMode mode) =>
      mode == AndroidScheduleMode.exactAllowWhileIdle ? 'exact' : 'inexact';

  Future<AndroidScheduleMode> _androidMode() async {
    if (!_client.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    final exact = await _client.plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.canScheduleExactNotifications();
    return (exact ?? false)
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }
}
