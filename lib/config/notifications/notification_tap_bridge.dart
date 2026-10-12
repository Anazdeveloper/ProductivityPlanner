import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:productivity_planner/config/router/app_routes.dart';
import 'package:productivity_planner/config/session/reminder_sync.dart';
import 'package:productivity_planner/config/session/subscription_sync.dart';
import 'package:productivity_planner/config/session/sync_scheduler.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_payload.dart';
import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';
import 'package:productivity_planner/features/notifications/domain/services/push_message_router.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reminder_actions.dart';

/// Connects notifications to navigation and to the reminder sync (main
/// isolate):
///
/// - a tapped reminder opens its occurrence;
/// - a reminder button pressed while the UI runs is handled here (the
///   background isolate handles it otherwise);
/// - a tapped push opens its validated route;
/// - a foreground `sync` push syncs now (and re-reconciles reminders);
/// - a `subscription` push (foreground or tapped) refreshes the
///   entitlement;
/// - the notification that launched the app is opened once at startup.
///
/// Locations go through the router, so the auth guard still applies (a
/// signed-out user goes to sign-in and lands on the target afterwards).
final class NotificationTapBridge {
  NotificationTapBridge({
    required LocalNotificationsClient localNotifications,
    required PushMessaging push,
    required HandleReminderAction handleReminderAction,
    required ReminderSync reminderSync,
    required SubscriptionSync subscriptionSync,
    required SyncScheduler syncScheduler,
    required GoRouter router,
    required ErrorReporter reporter,
  }) : _local = localNotifications,
       _push = push,
       _handleAction = handleReminderAction,
       _reminderSync = reminderSync,
       _subscriptionSync = subscriptionSync,
       _syncScheduler = syncScheduler,
       _router = router,
       _reporter = reporter;

  static const pushRouter = PushMessageRouter(
    defaults: {
      PushMessageType.account: AppRoutes.settings,
      PushMessageType.subscription: AppRoutes.subscription,
      PushMessageType.insight: AppRoutes.analytics,
    },
  );

  final LocalNotificationsClient _local;
  final PushMessaging _push;
  final HandleReminderAction _handleAction;
  final ReminderSync _reminderSync;
  final SubscriptionSync _subscriptionSync;
  final SyncScheduler _syncScheduler;
  final GoRouter _router;
  final ErrorReporter _reporter;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions
      ..add(_local.responses.listen(_onLocalResponse))
      ..add(_push.openedMessages().listen(_openPush))
      ..add(
        _push.foregroundMessages().listen((message) {
          switch (message.type) {
            case PushMessageType.sync:
              _syncScheduler.requestSync();
              _reminderSync.requestReconcile();
            case PushMessageType.subscription:
              _subscriptionSync.refreshNow();
            case PushMessageType.account ||
                PushMessageType.insight ||
                PushMessageType.unknown:
              break;
          }
        }),
      );
  }

  /// Opens what launched the app, if a notification did. Uses `go` (the
  /// stack is fresh); the router's redirect handles sign-in first.
  Future<void> openLaunchTarget() async {
    try {
      final local = await _local.launchResponse();
      final location = local == null
          ? await _launchPushLocation()
          : _locationOf(local.payload);
      if (location != null) _router.go(location);
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'launch'});
    }
  }

  Future<String?> _launchPushLocation() async {
    final message = await _push.launchMessage();
    return message == null ? null : pushRouter.locationFor(message);
  }

  void _onLocalResponse(LocalNotificationResponse response) {
    final action = response.action;
    final payload = response.payload;
    if (action != null && payload is ReminderPayload) {
      unawaited(_runAction(payload.occurrenceId, action));
      return;
    }
    final location = _locationOf(payload);
    if (location != null) unawaited(_router.push<void>(location));
  }

  void _openPush(PushMessage message) {
    if (message.type == PushMessageType.subscription) {
      _subscriptionSync.refreshNow();
    }
    final location = pushRouter.locationFor(message);
    if (location != null) unawaited(_router.push<void>(location));
  }

  static String? _locationOf(NotificationPayload payload) => switch (payload) {
    ReminderPayload(:final occurrenceId) => AppRoutes.occurrence(occurrenceId),
    PushPayload(:final type, :final route) => pushRouter.locationFor(
      PushMessage.fromData({'type': type, 'route': route}),
    ),
  };

  Future<void> _runAction(String occurrenceId, ReminderAction action) async {
    final result = await _handleAction(
      ReminderActionParams(occurrenceId: occurrenceId, action: action),
    );
    if (result case Err(:final failure)) {
      await _reporter.report(
        failure,
        StackTrace.current,
        context: {'step': 'reminder_action', 'action': action.name},
      );
    }
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
