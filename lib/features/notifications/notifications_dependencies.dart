import 'package:get_it/get_it.dart';
import 'package:productivity_planner/config/env/app_environment.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/notifications/data/datasources/firebase_push_messaging.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notification_permissions.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_notifications_client.dart';
import 'package:productivity_planner/features/notifications/data/datasources/local_reminder_scheduler.dart';
import 'package:productivity_planner/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:productivity_planner/features/notifications/data/datasources/notification_texts.dart';
import 'package:productivity_planner/features/notifications/data/mock/notification_mock_routes.dart';
import 'package:productivity_planner/features/notifications/data/repositories/meta_reminder_settings.dart';
import 'package:productivity_planner/features/notifications/data/repositories/notification_repositories_impl.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/reminder_scheduler.dart';
import 'package:productivity_planner/features/notifications/domain/services/reminder_planner.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/push.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reminder_actions.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_preferences_cubit.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';

/// Local reminders: everything needed to schedule, reconcile and handle
/// reminder buttons. Has no network or UI dependencies, so the background
/// isolate (notification actions, push wake-ups) registers exactly this.
///
/// Requires core, database and task registrations and a [HomeTimeZone].
void registerReminderDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton(
      () => NotificationTexts(converter: getIt<TimeZoneConverter>()),
    )
    ..registerLazySingleton(
      () => LocalNotificationsClient(texts: getIt<NotificationTexts>()),
      dispose: (client) => client.dispose(),
    )
    ..registerLazySingleton<ReminderScheduler>(
      () => LocalReminderScheduler(
        client: getIt<LocalNotificationsClient>(),
        texts: getIt<NotificationTexts>(),
      ),
    )
    ..registerLazySingleton<NotificationPermissions>(
      () => LocalNotificationPermissions(
        client: getIt<LocalNotificationsClient>(),
        meta: getIt<AppMetaStore>(),
      ),
    )
    ..registerLazySingleton<ReminderSettings>(
      () => MetaReminderSettings(getIt<AppMetaStore>()),
    )
    ..registerLazySingleton(ReminderPlanner.new);

  NotificationPermissions permissions() => getIt<NotificationPermissions>();
  ReminderSettings settings() => getIt<ReminderSettings>();
  getIt
    ..registerLazySingleton(
      () => ReconcileReminders(
        tasks: getIt<TaskRepository>(),
        scheduler: getIt<ReminderScheduler>(),
        permissions: permissions(),
        settings: settings(),
        planner: getIt<ReminderPlanner>(),
        homeTimeZone: getIt<HomeTimeZone>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(
      () => CancelAllReminders(
        scheduler: getIt<ReminderScheduler>(),
        settings: settings(),
      ),
    )
    ..registerLazySingleton(() => ActivateReminderSession(settings()))
    ..registerLazySingleton(
      () => HandleReminderAction(
        tasks: getIt<TaskRepository>(),
        scheduler: getIt<ReminderScheduler>(),
        reconcile: getIt<ReconcileReminders>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(
      () => GetNotificationAccess(
        permissions: permissions(),
        settings: settings(),
      ),
    )
    ..registerLazySingleton(
      () => RequestNotificationPermission(
        permissions: permissions(),
        settings: settings(),
      ),
    )
    ..registerLazySingleton(
      () => RequestExactAlarms(permissions: permissions(), settings: settings()),
    )
    ..registerLazySingleton(() => OpenNotificationSettings(permissions()))
    ..registerLazySingleton(() => SetRemindersEnabled(settings()))
    ..registerLazySingleton(() => WatchRemindersEnabled(settings()))
    ..registerLazySingleton(
      () => PromptForRemindersIfNeeded(
        permissions: permissions(),
        settings: settings(),
      ),
    );
}

/// Push, device registration, server preferences and the screens' cubits
/// (main isolate only). [pushEnabled] comes from bootstrap, which knows
/// whether Firebase could be initialized; without it push is a no-op and
/// local reminders work as usual.
void registerNotificationDependencies(
  GetIt getIt, {
  required bool pushEnabled,
}) {
  final environment = getIt<AppEnvironment>();
  if (environment.useMockApi) {
    NotificationMockBackend(
      clock: getIt<Clock>(),
    ).register(getIt<MockApiAdapter>());
  }

  getIt
    ..registerLazySingleton<PushMessaging>(
      () => pushEnabled
          ? FirebasePushMessaging(
              localNotifications: getIt<LocalNotificationsClient>(),
              logger: getIt<AppLogger>(),
            )
          : const NoopPushMessaging(),
    )
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => HttpNotificationRemoteDataSource(getIt<ApiHttpClient>()),
    )
    ..registerLazySingleton<DeviceRegistrationRepository>(
      () => DeviceRegistrationRepositoryImpl(
        remote: getIt<NotificationRemoteDataSource>(),
        deviceIds: getIt<DeviceIdProvider>(),
        device: getIt<DeviceContext>(),
        reporter: getIt<ErrorReporter>(),
      ),
    )
    ..registerLazySingleton<NotificationPreferencesRepository>(
      () => NotificationPreferencesRepositoryImpl(
        remote: getIt<NotificationRemoteDataSource>(),
        reporter: getIt<ErrorReporter>(),
      ),
    )
    ..registerLazySingleton(
      () => RegisterDevice(
        push: getIt<PushMessaging>(),
        settings: getIt<ReminderSettings>(),
        devices: getIt<DeviceRegistrationRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => LoadNotificationPreferences(
        getIt<NotificationPreferencesRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => SaveNotificationPreferences(
        getIt<NotificationPreferencesRepository>(),
      ),
    )
    // One app-wide cubit: Today's banner and the settings page show the
    // same state, and the permission prompt result must reach both.
    ..registerLazySingleton<NotificationCubit>(
      () => NotificationCubit(
        getAccess: getIt<GetNotificationAccess>(),
        requestPermission: getIt<RequestNotificationPermission>(),
        requestExactAlarms: getIt<RequestExactAlarms>(),
        openSettings: getIt<OpenNotificationSettings>(),
        setRemindersEnabled: getIt<SetRemindersEnabled>(),
        watchRemindersEnabled: getIt<WatchRemindersEnabled>(),
      ),
      dispose: (cubit) => cubit.close(),
    )
    ..registerFactory<NotificationPreferencesCubit>(
      () => NotificationPreferencesCubit(
        load: getIt<LoadNotificationPreferences>(),
        save: getIt<SaveNotificationPreferences>(),
      ),
    );
}
