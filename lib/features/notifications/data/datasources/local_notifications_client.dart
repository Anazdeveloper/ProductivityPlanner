import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:productivity_planner/features/notifications/data/datasources/notification_texts.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_payload.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reminder_actions.dart';

/// A user interaction with one of this app's local notifications.
final class LocalNotificationResponse {
  const LocalNotificationResponse({required this.payload, this.action});

  final NotificationPayload payload;

  /// Null for a tap on the notification itself.
  final ReminderAction? action;
}

/// The single owner of the `flutter_local_notifications` plugin: channels,
/// iOS categories (action buttons), initialization and responses. The
/// scheduler and permission adapters share it.
final class LocalNotificationsClient {
  LocalNotificationsClient({
    required NotificationTexts texts,
    FlutterLocalNotificationsPlugin? plugin,
    TargetPlatform? platform,
  }) : _texts = texts,
       plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       platform = platform ?? defaultTargetPlatform;

  static const remindersChannelId = 'task_reminders';
  static const updatesChannelId = 'account_updates';
  static const reminderCategoryId = 'task_reminder';
  static const doneActionId = 'reminder.done';
  static const snoozeActionId = 'reminder.snooze';

  /// Android small icon: the launcher icon until a monochrome
  /// `ic_stat_notification` drawable is added (Phase 13 store checklist).
  static const _androidIcon = '@mipmap/ic_launcher';

  final NotificationTexts _texts;
  final FlutterLocalNotificationsPlugin plugin;
  final TargetPlatform platform;

  final _responses = StreamController<LocalNotificationResponse>.broadcast();
  Future<void>? _initializing;

  /// Taps and foreground action presses (main isolate).
  Stream<LocalNotificationResponse> get responses => _responses.stream;

  bool get isAndroid => platform == TargetPlatform.android;

  bool get isIos => platform == TargetPlatform.iOS;

  /// Idempotent. Never prompts for permission (that is an explicit,
  /// in-context step). [onBackgroundResponse] must be a top-level function
  /// annotated `@pragma('vm:entry-point')`; it runs in a separate isolate
  /// for action buttons pressed while the UI is not running.
  Future<void> initialize({
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) => _initializing ??= _initialize(onBackgroundResponse);

  Future<void> _initialize(
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  ) async {
    final l10n = _texts.l10n;
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          reminderCategoryId,
          actions: [
            DarwinNotificationAction.plain(
              doneActionId,
              l10n.reminderActionDone,
            ),
            DarwinNotificationAction.plain(
              snoozeActionId,
              l10n.reminderActionSnooze,
            ),
          ],
        ),
      ],
    );
    await plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings(_androidIcon),
        iOS: darwin,
      ),
      onDidReceiveNotificationResponse: (response) {
        final parsed = parseResponse(response);
        if (parsed != null) _responses.add(parsed);
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    if (isAndroid) {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          remindersChannelId,
          l10n.reminderChannelName,
          description: l10n.reminderChannelDescription,
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        AndroidNotificationChannel(
          updatesChannelId,
          l10n.updatesChannelName,
          description: l10n.updatesChannelDescription,
        ),
      );
    }
  }

  /// The notification that launched the app from terminated, if any.
  Future<LocalNotificationResponse?> launchResponse() async {
    await initialize();
    final details = await plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details == null || !details.didNotificationLaunchApp) return null;
    return response == null ? null : parseResponse(response);
  }

  /// Platform details for a task reminder (with Done / Snooze buttons).
  NotificationDetails reminderDetails() {
    final l10n = _texts.l10n;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        remindersChannelId,
        l10n.reminderChannelName,
        channelDescription: l10n.reminderChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        actions: [
          AndroidNotificationAction(doneActionId, l10n.reminderActionDone),
          AndroidNotificationAction(snoozeActionId, l10n.reminderActionSnooze),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: reminderCategoryId,
        threadIdentifier: remindersChannelId,
      ),
    );
  }

  /// Shows a push received while the app is in the foreground (Android
  /// does not display those by itself; iOS does, via presentation options).
  Future<void> showPush({
    required int id,
    required String? title,
    required String? body,
    required String? type,
    required String? route,
  }) async {
    await initialize();
    final l10n = _texts.l10n;
    await plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          updatesChannelId,
          l10n.updatesChannelName,
          channelDescription: l10n.updatesChannelDescription,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: PushPayload(type: type, route: route).encode(),
    );
  }

  /// Null for responses to notifications this app did not create.
  static LocalNotificationResponse? parseResponse(
    NotificationResponse response,
  ) {
    final payload = NotificationPayload.decode(response.payload);
    if (payload == null) return null;
    final action = switch (response.actionId) {
      doneActionId => ReminderAction.done,
      snoozeActionId => ReminderAction.snooze,
      _ => null,
    };
    return LocalNotificationResponse(payload: payload, action: action);
  }

  Future<void> dispose() => _responses.close();
}

/// Kept here so domain ids and platform ids cannot drift apart.
int pushNotificationId(String? messageId) =>
    stableHash('push|${messageId ?? DateTime.now().microsecondsSinceEpoch}');
