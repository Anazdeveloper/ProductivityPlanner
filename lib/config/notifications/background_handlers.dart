import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:productivity_planner/config/di/injection.dart';
import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_payload.dart';
import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reminder_actions.dart';
import 'package:productivity_planner/features/notifications/notifications_dependencies.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/tasks_dependencies.dart';

// Entry points the platform calls in a separate isolate, with the app's UI
// possibly not running: reminder buttons (Done / Snooze) and data-only
// pushes. Each builds a small dependency graph (database, tasks, reminders;
// no network, auth or UI), does one job and closes it.
//
// The database is opened with `shareAcrossIsolates`, so when the app is
// also running both isolates use one connection and the UI sees the change
// immediately.

/// `onDidReceiveBackgroundNotificationResponse` for local notifications.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  final parsed = LocalNotificationsClient.parseResponse(response);
  final action = parsed?.action;
  final payload = parsed?.payload;
  if (action == null || payload is! ReminderPayload) return;
  unawaited(
    _runInBackground((getIt) async {
      await getIt<HandleReminderAction>()(
        ReminderActionParams(
          occurrenceId: payload.occurrenceId,
          action: action,
        ),
      );
    }),
  );
}

/// `FirebaseMessaging.onBackgroundMessage` handler. Only `sync` pings do
/// work: top up occurrences and reminders (the full pull arrives with the
/// sync engine in Phase 11). Display pushes are shown by the OS.
@pragma('vm:entry-point')
Future<void> onBackgroundPushMessage(RemoteMessage message) async {
  final push = PushMessage.fromData(message.data);
  if (push.type != PushMessageType.sync) return;
  await _runInBackground((getIt) async {
    await getIt<EnsureOccurrencesMaterialized>()(const NoParams());
    await getIt<ReconcileReminders>()(const NoParams());
  });
}

Future<void> _runInBackground(
  Future<void> Function(GetIt getIt) job,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final logger = DeveloperLogger(minLevel: LogLevel.info);
  final reporter = LoggingErrorReporter(logger);
  final getIt = GetIt.asNewInstance();
  try {
    _registerBackgroundCore(getIt, logger: logger, reporter: reporter);
    registerDatabaseDependencies(getIt);
    getIt.registerLazySingleton<HomeTimeZone>(
      () => _DeviceHomeTimeZone(getIt<DeviceContext>()),
    );
    registerTaskDependencies(getIt);
    registerReminderDependencies(getIt);

    // Nothing to do without a signed-in session: its reminders were
    // cancelled at sign-out, and a stale button press or push is ignored.
    if (!await getIt<ReminderSettings>().remindersSessionActive()) return;
    await getIt<LocalNotificationsClient>().initialize();
    await job(getIt);
  } on Object catch (error, stackTrace) {
    await reporter.report(error, stackTrace, context: {'isolate': 'background'});
  } finally {
    // Runs the registered disposers (closes the database connection) for
    // whatever was actually created.
    await getIt.reset();
  }
}

void _registerBackgroundCore(
  GetIt getIt, {
  required AppLogger logger,
  required ErrorReporter reporter,
}) {
  getIt
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<ErrorReporter>(reporter)
    ..registerLazySingleton<Clock>(SystemClock.new)
    ..registerLazySingleton<IdGenerator>(UuidV7IdGenerator.new)
    ..registerLazySingleton<DeviceContext>(PlatformDeviceContext.new)
    ..registerLazySingleton<TimeZoneConverter>(TzTimeZoneConverter.new);
}

/// No session is restored in the background; the device zone is close
/// enough to choose which days' reminders to look at (the window already
/// spans yesterday to two weeks ahead).
final class _DeviceHomeTimeZone implements HomeTimeZone {
  const _DeviceHomeTimeZone(this._device);

  final DeviceContext _device;

  @override
  Future<String> current() => _device.timeZone();
}
