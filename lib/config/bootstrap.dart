import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_planner/config/app.dart';
import 'package:productivity_planner/config/di/injection.dart';
import 'package:productivity_planner/config/env/app_environment.dart';
import 'package:productivity_planner/config/notifications/background_handlers.dart';
import 'package:productivity_planner/config/notifications/notification_tap_bridge.dart';
import 'package:productivity_planner/config/session/device_sync.dart';
import 'package:productivity_planner/config/session/fresh_install_guard.dart';
import 'package:productivity_planner/config/session/reminder_sync.dart';
import 'package:productivity_planner/config/session/subscription_sync.dart';
import 'package:productivity_planner/config/session/sync_scheduler.dart';
import 'package:productivity_planner/config/session/user_session_coordinator.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/logging/app_bloc_observer.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/features/auth/data/datasources/session_storage.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:productivity_planner/features/notifications/data/datasources/firebase_push_messaging.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';

/// Shared startup for every flavor entry point.
Future<void> bootstrap(Flavor flavor) async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  final environment = AppEnvironment.fromDartDefines(flavor);

  final logger = DeveloperLogger(
    minLevel: environment.isProduction ? LogLevel.info : LogLevel.debug,
  );
  // Phase 13 swaps in the Sentry reporter here; nothing else changes.
  final reporter = LoggingErrorReporter(logger);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      reporter.report(
        details.exception,
        details.stack ?? StackTrace.current,
        fatal: true,
        context: {'library': details.library},
      ),
    );
  };
  binding.platformDispatcher.onError = (error, stackTrace) {
    unawaited(reporter.report(error, stackTrace, fatal: true));
    return true;
  };
  Bloc.observer = AppBlocObserver(logger: logger, reporter: reporter);

  // Push needs the native Firebase config files; without them (mock builds,
  // a fresh checkout) the app runs with local reminders only.
  final pushEnabled =
      !environment.useMockApi && await initializeFirebase(logger);
  if (pushEnabled) {
    FirebaseMessaging.onBackgroundMessage(onBackgroundPushMessage);
  }

  await configureDependencies(
    environment,
    logger: logger,
    reporter: reporter,
    pushEnabled: pushEnabled,
  );
  // Opens the database; on a fresh install, drops a Keychain session that
  // survived the uninstall (iOS). Must precede the session restore.
  await discardSessionFromPreviousInstall(
    database: sl<AppDatabase>(),
    sessionStorage: sl<SessionStorage>(),
    logger: logger,
    reporter: reporter,
  );
  // Listens before the restore so the first signed-in state binds the
  // local data to that user.
  final sessionCoordinator = sl<UserSessionCoordinator>()..start();
  // Notifications: channels and action categories before anything is
  // scheduled; never prompts here (the prompt comes in context).
  await sl<LocalNotificationsClient>().initialize(
    onBackgroundResponse: onBackgroundNotificationResponse,
  );
  final reminderSync = sl<ReminderSync>()..start();
  final deviceSync = sl<DeviceSync>()..start();
  final subscriptionSync = sl<SubscriptionSync>()..start();
  // Runs once the coordinator has the user's data ready, then on changes,
  // resume, reconnect and a timer; never assumes the device is online.
  final syncScheduler = sl<SyncScheduler>()..start();
  // Registers itself with the binding, which keeps it alive for the app's
  // lifetime.
  AppLifecycleListener(
    onResume: () {
      sessionCoordinator.appResumed();
      reminderSync.appResumed();
      deviceSync.appResumed();
      subscriptionSync.appResumed();
      syncScheduler.appResumed();
    },
    onHide: () {
      reminderSync.appPaused();
      syncScheduler.appPaused();
    },
  );
  // Reads the stored session (no network); the router waits on the splash
  // until this resolves.
  sl<AuthBloc>().add(const AuthStarted());
  logger.info(
    'app started',
    context: {'flavor': flavor.name, 'mock_api': environment.useMockApi},
  );

  final router = sl<GoRouter>();
  final taps = sl<NotificationTapBridge>()..start();
  runApp(App(router: router));
  // After the first frame so the router is attached; the auth redirect
  // holds the target until the session is known.
  unawaited(taps.openLaunchTarget());
}
