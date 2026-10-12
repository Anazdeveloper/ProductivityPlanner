import 'dart:async';

import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';
import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/reminder_scheduler.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/push.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_preferences_cubit.dart';

/// Holds "scheduled" reminders in memory, like the platform would.
final class FakeReminderScheduler implements ReminderScheduler {
  final Map<int, ReminderRequest> scheduled = {};
  int scheduleCalls = 0;
  int cancelCalls = 0;

  List<ReminderRequest> get reminders => scheduled.values
      .where((r) => r.kind == ReminderKind.reminder)
      .toList();

  List<ReminderRequest> get snoozes =>
      scheduled.values.where((r) => r.kind == ReminderKind.snooze).toList();

  @override
  Future<List<ScheduledReminder>> pending() async => [
    for (final r in scheduled.values)
      ScheduledReminder(
        id: r.id,
        occurrenceId: r.occurrenceId,
        kind: r.kind,
        fingerprint: r.fingerprint,
      ),
  ];

  @override
  Future<void> schedule(ReminderRequest request) async {
    scheduleCalls++;
    scheduled[request.id] = request;
  }

  @override
  Future<void> cancel(int id) async {
    cancelCalls++;
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAll() async => scheduled.clear();
}

final class FakeNotificationPermissions implements NotificationPermissions {
  FakeNotificationPermissions({
    this.permission = NotificationPermission.granted,
    this.onRequest = NotificationPermission.granted,
    this.exactAlarms,
  });

  NotificationPermission permission;

  /// What the "user" answers when prompted.
  NotificationPermission onRequest;
  bool? exactAlarms;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<NotificationPermission> status() async => permission;

  @override
  Future<NotificationPermission> request() async {
    requests++;
    if (permission == NotificationPermission.notDetermined) {
      permission = onRequest;
    }
    return permission;
  }

  @override
  Future<bool?> exactAlarmsAllowed() async => exactAlarms;

  @override
  Future<bool?> requestExactAlarms() async {
    if (exactAlarms != null) exactAlarms = true;
    return exactAlarms;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;
}

final class FakeReminderSettings implements ReminderSettings {
  FakeReminderSettings({bool enabled = true}) : _enabled = enabled;

  bool _enabled;
  bool promptShown = false;
  final _changes = StreamController<bool>.broadcast(sync: true);

  @override
  Future<bool> remindersEnabled() async => _enabled;

  @override
  Future<void> setRemindersEnabled({required bool enabled}) async {
    _enabled = enabled;
    _changes.add(enabled);
  }

  @override
  Stream<bool> watchRemindersEnabled() => Stream<bool>.multi((c) {
    c.add(_enabled);
    final sub = _changes.stream.listen(c.add);
    c.onCancel = sub.cancel;
  });

  @override
  Future<bool> permissionPromptShown() async => promptShown;

  @override
  Future<void> markPermissionPromptShown() async => promptShown = true;

  bool sessionActive = false;

  @override
  Future<bool> remindersSessionActive() async => sessionActive;

  @override
  Future<void> setRemindersSessionActive({required bool active}) async =>
      sessionActive = active;
}

final class FakePushMessaging implements PushMessaging {
  FakePushMessaging({this.currentToken = 'token-1'});

  String? currentToken;
  final refreshes = StreamController<String>.broadcast(sync: true);
  final foreground = StreamController<PushMessage>.broadcast(sync: true);
  final opened = StreamController<PushMessage>.broadcast(sync: true);
  PushMessage? launch;

  @override
  Future<String?> token() async => currentToken;

  @override
  Stream<String> tokenRefreshes() => refreshes.stream;

  @override
  Stream<PushMessage> foregroundMessages() => foreground.stream;

  @override
  Stream<PushMessage> openedMessages() => opened.stream;

  @override
  Future<PushMessage?> launchMessage() async {
    final message = launch;
    launch = null;
    return message;
  }
}

final class FakeDeviceRegistrationRepository
    implements DeviceRegistrationRepository {
  final List<(String?, bool)> calls = [];
  Failure? nextFailure;

  @override
  Future<Result<Unit>> register({
    required String? pushToken,
    required bool remindersEnabled,
  }) async {
    calls.add((pushToken, remindersEnabled));
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Err(failure);
    }
    return const Ok(unit);
  }
}

final class FakeNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  NotificationPreferences stored = const NotificationPreferences();
  Failure? loadFailure;
  Failure? saveFailure;

  @override
  Future<Result<NotificationPreferences>> load() async {
    final failure = loadFailure;
    return failure == null ? Ok(stored) : Err(failure);
  }

  @override
  Future<Result<NotificationPreferences>> save(
    NotificationPreferences preferences,
  ) async {
    final failure = saveFailure;
    if (failure != null) return Err(failure);
    stored = preferences;
    return Ok(stored);
  }
}

NotificationCubit buildNotificationCubit({
  required NotificationPermissions permissions,
  required ReminderSettings settings,
}) => NotificationCubit(
  getAccess: GetNotificationAccess(
    permissions: permissions,
    settings: settings,
  ),
  requestPermission: RequestNotificationPermission(
    permissions: permissions,
    settings: settings,
  ),
  requestExactAlarms: RequestExactAlarms(
    permissions: permissions,
    settings: settings,
  ),
  openSettings: OpenNotificationSettings(permissions),
  setRemindersEnabled: SetRemindersEnabled(settings),
  watchRemindersEnabled: WatchRemindersEnabled(settings),
);

NotificationPreferencesCubit buildPreferencesCubit(
  NotificationPreferencesRepository repository,
) => NotificationPreferencesCubit(
  load: LoadNotificationPreferences(repository),
  save: SaveNotificationPreferences(repository),
);
