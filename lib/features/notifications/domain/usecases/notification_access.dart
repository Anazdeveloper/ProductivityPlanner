import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';

/// Platform calls can throw (plugin missing in tests, OS quirks); every use
/// case here turns that into a [Failure] instead.
Future<Result<T>> _guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Object catch (error, stackTrace) {
    return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
  }
}

Future<NotificationAccess> _readAccess(
  NotificationPermissions permissions,
  ReminderSettings settings,
) async => NotificationAccess(
  permission: await permissions.status(),
  exactAlarmsAllowed: await permissions.exactAlarmsAllowed(),
  remindersEnabled: await settings.remindersEnabled(),
);

final class GetNotificationAccess
    implements UseCase<NotificationAccess, NoParams> {
  const GetNotificationAccess({
    required NotificationPermissions permissions,
    required ReminderSettings settings,
  }) : _permissions = permissions,
       _settings = settings;

  final NotificationPermissions _permissions;
  final ReminderSettings _settings;

  @override
  Future<Result<NotificationAccess>> call(NoParams params) =>
      _guard(() => _readAccess(_permissions, _settings));
}

/// The user asked to turn notifications on. Prompts if the OS still allows
/// a prompt; when the permission was refused before, opens the system
/// settings instead (the only place it can change).
final class RequestNotificationPermission
    implements UseCase<NotificationAccess, NoParams> {
  const RequestNotificationPermission({
    required NotificationPermissions permissions,
    required ReminderSettings settings,
  }) : _permissions = permissions,
       _settings = settings;

  final NotificationPermissions _permissions;
  final ReminderSettings _settings;

  @override
  Future<Result<NotificationAccess>> call(NoParams params) => _guard(() async {
    final current = await _permissions.status();
    if (current == NotificationPermission.denied) {
      await _permissions.openSystemSettings();
    } else if (current == NotificationPermission.notDetermined) {
      await _permissions.request();
      await _settings.markPermissionPromptShown();
    }
    return await _readAccess(_permissions, _settings);
  });
}

/// Android 12+: lets reminders fire at the exact minute.
final class RequestExactAlarms
    implements UseCase<NotificationAccess, NoParams> {
  const RequestExactAlarms({
    required NotificationPermissions permissions,
    required ReminderSettings settings,
  }) : _permissions = permissions,
       _settings = settings;

  final NotificationPermissions _permissions;
  final ReminderSettings _settings;

  @override
  Future<Result<NotificationAccess>> call(NoParams params) => _guard(() async {
    await _permissions.requestExactAlarms();
    return await _readAccess(_permissions, _settings);
  });
}

final class OpenNotificationSettings implements UseCase<Unit, NoParams> {
  const OpenNotificationSettings(this._permissions);

  final NotificationPermissions _permissions;

  @override
  Future<Result<Unit>> call(NoParams params) => _guard(() async {
    await _permissions.openSystemSettings();
    return unit;
  });
}

/// The in-app "Task reminders" switch. Reminders are reconciled by the
/// session's reminder sync, which watches this setting.
final class SetRemindersEnabled implements UseCase<Unit, bool> {
  const SetRemindersEnabled(this._settings);

  final ReminderSettings _settings;

  @override
  Future<Result<Unit>> call(bool enabled) => _guard(() async {
    await _settings.setRemindersEnabled(enabled: enabled);
    return unit;
  });
}

final class WatchRemindersEnabled {
  const WatchRemindersEnabled(this._settings);

  final ReminderSettings _settings;

  Stream<bool> call() => _settings.watchRemindersEnabled();
}

/// Asks for the notification permission once, in context: right after a
/// reconciliation found reminders that could not be scheduled because the
/// user has never been asked. Returns whether it prompted.
final class PromptForRemindersIfNeeded
    implements UseCase<bool, ReconcileReport> {
  const PromptForRemindersIfNeeded({
    required NotificationPermissions permissions,
    required ReminderSettings settings,
  }) : _permissions = permissions,
       _settings = settings;

  final NotificationPermissions _permissions;
  final ReminderSettings _settings;

  @override
  Future<Result<bool>> call(ReconcileReport report) => _guard(() async {
    if (report.wanted == 0 ||
        !report.remindersEnabled ||
        report.permission != NotificationPermission.notDetermined ||
        await _settings.permissionPromptShown()) {
      return false;
    }
    await _settings.markPermissionPromptShown();
    await _permissions.request();
    return true;
  });
}
