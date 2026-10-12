import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_planner/config/env/app_environment.dart';
import 'package:productivity_planner/config/notifications/notification_tap_bridge.dart';
import 'package:productivity_planner/config/router/app_router.dart';
import 'package:productivity_planner/config/router/auth_bloc_auth_gate.dart';
import 'package:productivity_planner/config/session/device_sync.dart';
import 'package:productivity_planner/config/session/profile_home_time_zone.dart';
import 'package:productivity_planner/config/session/reminder_sync.dart';
import 'package:productivity_planner/config/session/subscription_sync.dart';
import 'package:productivity_planner/config/session/sync_scheduler.dart';
import 'package:productivity_planner/config/session/user_session_coordinator.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/database/database_connection.dart';
import 'package:productivity_planner/core/database/user_data_store.dart';
import 'package:productivity_planner/core/device/connectivity_monitor.dart';
import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/device/persistent_device_id_provider.dart';
import 'package:productivity_planner/core/device/url_opener.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/mock/core_mock_routes.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';
import 'package:productivity_planner/core/sync/sync_mock_backend.dart';
import 'package:productivity_planner/core/sync/sync_remote_data_source.dart';
import 'package:productivity_planner/core/sync/sync_stores.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/analytics/analytics_dependencies.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/activity_analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/analytics_cubit.dart';
import 'package:productivity_planner/features/auth/auth_dependencies.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/password_reset_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/register_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/sign_in_cubit.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/push.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reminder_actions.dart';
import 'package:productivity_planner/features/notifications/notifications_dependencies.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_preferences_cubit.dart';
import 'package:productivity_planner/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:productivity_planner/features/profile/profile_dependencies.dart';
import 'package:productivity_planner/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:productivity_planner/features/subscription/presentation/bloc/subscription_cubit.dart';
import 'package:productivity_planner/features/subscription/subscription_dependencies.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:productivity_planner/features/sync/sync_dependencies.dart';
import 'package:productivity_planner/features/tasks/data/sync/task_sync_handler.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_detail_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/tasks_dependencies.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';
import 'package:productivity_planner/features/voice/voice_dependencies.dart';

/// The app's single service locator. Only the composition root (config/) and
/// each feature's `*_dependencies.dart` registrar may touch it; widgets,
/// blocs and use cases receive their dependencies through constructors.
/// test/architecture enforces this.
final GetIt sl = GetIt.instance;

/// Registers everything. Most registrations are lazy, so order only matters
/// for the few eager calls (mock route registration, navigation).
///
/// [database] lets tests supply an in-memory database. [pushEnabled] is
/// true when Firebase was initialized (bootstrap decides).
///
/// [connectivity] lets tests replace the platform plugin.
Future<void> configureDependencies(
  AppEnvironment environment, {
  required AppLogger logger,
  required ErrorReporter reporter,
  GetIt? locator,
  AppDatabase? database,
  bool pushEnabled = false,
  ConnectivityMonitor? connectivity,
}) async {
  final getIt = locator ?? sl;
  registerCoreDependencies(
    getIt,
    environment: environment,
    logger: logger,
    reporter: reporter,
  );
  registerDatabaseDependencies(getIt, database: database);
  registerNetworkDependencies(getIt);
  registerAuthDependencies(getIt);
  registerSubscriptionDependencies(getIt);
  registerProfileDependencies(getIt);
  registerTaskDependencies(getIt);
  registerAnalyticsDependencies(getIt);
  registerVoiceDependencies(getIt);
  registerSyncDependencies(getIt, connectivity: connectivity);
  registerSyncFeatureDependencies(getIt);
  registerSessionDependencies(getIt);
  registerReminderDependencies(getIt);
  registerNotificationDependencies(getIt, pushEnabled: pushEnabled);
  registerNotificationSessionDependencies(getIt);
  registerNavigationDependencies(getIt);
  registerNotificationNavigationDependencies(getIt);
}

/// Logger and reporter are created in bootstrap (before DI) so that errors
/// during startup are captured too; they are registered here for injection.
void registerCoreDependencies(
  GetIt getIt, {
  required AppEnvironment environment,
  required AppLogger logger,
  required ErrorReporter reporter,
}) {
  getIt
    ..registerSingleton<AppEnvironment>(environment)
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<ErrorReporter>(reporter)
    ..registerLazySingleton<Clock>(SystemClock.new)
    ..registerLazySingleton<Ticker>(() => PeriodicTicker(getIt<Clock>()))
    ..registerLazySingleton<IdGenerator>(UuidV7IdGenerator.new)
    ..registerLazySingleton<DeviceContext>(PlatformDeviceContext.new)
    ..registerLazySingleton<TimeZoneConverter>(TzTimeZoneConverter.new)
    ..registerLazySingleton<UrlOpener>(PlatformUrlOpener.new);
}

/// The local database and the core services built on it.
void registerDatabaseDependencies(GetIt getIt, {AppDatabase? database}) {
  getIt
    ..registerLazySingleton<AppDatabase>(
      () => database ?? openAppDatabase(),
      dispose: (db) => db.close(),
    )
    ..registerLazySingleton(() => AppMetaStore(getIt<AppDatabase>()))
    ..registerLazySingleton<DeviceIdProvider>(
      () => PersistentDeviceIdProvider(
        meta: getIt<AppMetaStore>(),
        ids: getIt<IdGenerator>(),
      ),
    )
    ..registerLazySingleton(
      () => OutboxWriter(
        db: getIt<AppDatabase>(),
        ids: getIt<IdGenerator>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(
      () => UserDataStore(
        db: getIt<AppDatabase>(),
        meta: getIt<AppMetaStore>(),
      ),
    );
}

/// The sync engine (core) with each feature's entity handler; the
/// composition root is the one place that knows them all.
void registerSyncDependencies(
  GetIt getIt, {
  ConnectivityMonitor? connectivity,
}) {
  if (getIt<AppEnvironment>().useMockApi) {
    SyncMockBackend().register(getIt<MockApiAdapter>());
  }
  getIt
    ..registerLazySingleton<ConnectivityMonitor>(
      () => connectivity ?? PlatformConnectivityMonitor(),
    )
    ..registerLazySingleton(() => OutboxStore(getIt<AppDatabase>()))
    ..registerLazySingleton(() => SyncCursorStore(getIt<AppMetaStore>()))
    ..registerLazySingleton(() => SyncIssueStore(getIt<AppDatabase>()))
    ..registerLazySingleton<SyncRemoteDataSource>(
      () => HttpSyncRemoteDataSource(getIt<ApiHttpClient>()),
    )
    ..registerLazySingleton(
      () => SyncEngine(
        db: getIt<AppDatabase>(),
        remote: getIt<SyncRemoteDataSource>(),
        outbox: getIt<OutboxStore>(),
        cursor: getIt<SyncCursorStore>(),
        issues: getIt<SyncIssueStore>(),
        deviceIds: getIt<DeviceIdProvider>(),
        handlers: [getIt<TaskSyncHandler>()],
        ids: getIt<IdGenerator>(),
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
        reporter: getIt<ErrorReporter>(),
      ),
      dispose: (engine) => engine.dispose(),
    );
}

/// Glue between features that must not import each other (auth and tasks).
/// [HomeTimeZone] is resolved lazily, so registering it after the tasks
/// registrar is fine.
void registerSessionDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<HomeTimeZone>(
      () => ProfileHomeTimeZone(
        watchAuthState: getIt<WatchAuthState>(),
        device: getIt<DeviceContext>(),
      ),
    )
    ..registerLazySingleton(
      () => UserSessionCoordinator(
        watchAuthState: getIt<WatchAuthState>(),
        userData: getIt<UserDataStore>(),
        ensureDefaultCategories: getIt<EnsureDefaultCategories>(),
        ensureOccurrences: getIt<EnsureOccurrencesMaterialized>(),
        syncEngine: getIt<SyncEngine>(),
        logger: getIt<AppLogger>(),
        reporter: getIt<ErrorReporter>(),
      ),
      dispose: (coordinator) => coordinator.dispose(),
    )
    ..registerLazySingleton(
      () => SyncScheduler(
        watchPreparedUser:
            getIt<UserSessionCoordinator>().watchPreparedUser,
        engine: getIt<SyncEngine>(),
        outbox: getIt<OutboxWriter>(),
        connectivity: getIt<ConnectivityMonitor>(),
        logger: getIt<AppLogger>(),
      ),
      dispose: (scheduler) => scheduler.dispose(),
    )
    ..registerLazySingleton(
      () => SubscriptionSync(
        watchAuthState: getIt<WatchAuthState>(),
        subscriptions: getIt<SubscriptionRepository>(),
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
      ),
      dispose: (sync) => sync.dispose(),
    );
}

/// Reminder sync and device registration: they follow the session, so they
/// join auth, tasks and notifications here.
void registerNotificationSessionDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton(
      () => ReminderSync(
        watchAuthState: getIt<WatchAuthState>(),
        watchAgenda: getIt<WatchAgenda>(),
        getHomeToday: getIt<GetHomeToday>(),
        reconcile: getIt<ReconcileReminders>(),
        activate: getIt<ActivateReminderSession>(),
        cancelAll: getIt<CancelAllReminders>(),
        promptIfNeeded: getIt<PromptForRemindersIfNeeded>(),
        watchRemindersEnabled: getIt<WatchRemindersEnabled>(),
        ticker: getIt<Ticker>(),
        logger: getIt<AppLogger>(),
        reporter: getIt<ErrorReporter>(),
      ),
      dispose: (sync) => sync.dispose(),
    )
    ..registerLazySingleton(
      () => DeviceSync(
        watchAuthState: getIt<WatchAuthState>(),
        push: getIt<PushMessaging>(),
        watchRemindersEnabled: getIt<WatchRemindersEnabled>(),
        registerDevice: getIt<RegisterDevice>(),
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
      ),
      dispose: (sync) => sync.dispose(),
    );
}

/// Notification taps and launch targets need the router.
void registerNotificationNavigationDependencies(GetIt getIt) {
  getIt.registerLazySingleton(
    () => NotificationTapBridge(
      localNotifications: getIt<LocalNotificationsClient>(),
      push: getIt<PushMessaging>(),
      handleReminderAction: getIt<HandleReminderAction>(),
      reminderSync: getIt<ReminderSync>(),
      subscriptionSync: getIt<SubscriptionSync>(),
      syncScheduler: getIt<SyncScheduler>(),
      router: getIt<GoRouter>(),
      reporter: getIt<ErrorReporter>(),
    ),
    dispose: (bridge) => bridge.dispose(),
  );
}

/// The authenticated client needs an [AuthTokenProvider], registered by the
/// auth feature; it is resolved lazily on first use.
void registerNetworkDependencies(GetIt getIt) {
  final environment = getIt<AppEnvironment>();

  if (environment.useMockApi) {
    final adapter = MockApiAdapter(latency: const Duration(milliseconds: 250));
    registerCoreMockRoutes(adapter, clock: getIt<Clock>());
    getIt.registerSingleton<MockApiAdapter>(adapter);
  }

  HttpClientConfig config() => HttpClientConfig(
    baseUrl: environment.apiBaseUrl,
    ids: getIt<IdGenerator>(),
    deviceIds: getIt<DeviceIdProvider>(),
    logger: getIt<AppLogger>(),
    adapter: environment.useMockApi ? getIt<MockApiAdapter>() : null,
  );

  getIt
    ..registerLazySingleton<PublicHttpClient>(
      () => createPublicHttpClient(config()),
      dispose: (client) => client.dio.close(),
    )
    ..registerLazySingleton<ApiHttpClient>(
      () => createApiHttpClient(
        config(),
        tokens: getIt<AuthTokenProvider>(),
        retryClient: getIt<PublicHttpClient>(),
      ),
      dispose: (client) => client.dio.close(),
    );
}

void registerNavigationDependencies(GetIt getIt) {
  final authBloc = getIt<AuthBloc>();
  final authGate = AuthBlocAuthGate(authBloc);
  getIt
    ..registerSingleton<AuthBlocAuthGate>(
      authGate,
      dispose: (gate) => gate.dispose(),
    )
    ..registerLazySingleton<GoRouter>(
      () => createAppRouter(
        authGate: authGate,
        blocs: RouteBlocFactories(
          signInCubit: () => getIt<SignInCubit>(),
          registerCubit: () => getIt<RegisterCubit>(),
          passwordResetCubit: (email) =>
              getIt<PasswordResetCubit>(param1: email),
          profileCubit: () => getIt<ProfileCubit>(),
          dailyPlannerCubit: (scope) => getIt<DailyPlannerCubit>(param1: scope),
          taskEditorCubit: (args) => getIt<TaskEditorCubit>(param1: args),
          taskDetailCubit: (id) => getIt<TaskDetailCubit>(param1: id),
          focusTimerBloc: (target) => getIt<FocusTimerBloc>(param1: target),
          analyticsCubit: () => getIt<AnalyticsCubit>(),
          activityAnalyticsCubit: (lineageId) =>
              getIt<ActivityAnalyticsCubit>(param1: lineageId),
          voiceCaptureBloc: () => getIt<VoiceCaptureBloc>(),
          subscriptionCubit: () => getIt<SubscriptionCubit>(),
          syncStatusCubit: () => getIt<SyncStatusCubit>(),
          openUrl: (uri) => unawaited(getIt<UrlOpener>().open(uri)),
          notificationCubit: () => getIt<NotificationCubit>(),
          notificationPreferencesCubit: () =>
              getIt<NotificationPreferencesCubit>(),
          onTaskSaved: () =>
              getIt<ReminderSync>().requestReconcile(allowPrompt: true),
          onSignOut: () => authBloc.add(const AuthSignOutRequested()),
        ),
      ),
      dispose: (router) => router.dispose(),
    );
}
