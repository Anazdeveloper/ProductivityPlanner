import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';

/// Tells the server how to reach this install (`PUT devices/{id}`). Run on
/// sign-in, on token refresh and when the reminders switch changes.
final class RegisterDevice implements UseCase<Unit, NoParams> {
  const RegisterDevice({
    required PushMessaging push,
    required ReminderSettings settings,
    required DeviceRegistrationRepository devices,
  }) : _push = push,
       _settings = settings,
       _devices = devices;

  final PushMessaging _push;
  final ReminderSettings _settings;
  final DeviceRegistrationRepository _devices;

  @override
  Future<Result<Unit>> call(NoParams params) async {
    final String? token;
    final bool enabled;
    try {
      token = await _push.token();
      enabled = await _settings.remindersEnabled();
    } on Object catch (error, stackTrace) {
      return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
    }
    return await _devices.register(pushToken: token, remindersEnabled: enabled);
  }
}

final class LoadNotificationPreferences
    implements UseCase<NotificationPreferences, NoParams> {
  const LoadNotificationPreferences(this._repository);

  final NotificationPreferencesRepository _repository;

  @override
  Future<Result<NotificationPreferences>> call(NoParams params) =>
      _repository.load();
}

final class SaveNotificationPreferences
    implements UseCase<NotificationPreferences, NotificationPreferences> {
  const SaveNotificationPreferences(this._repository);

  final NotificationPreferencesRepository _repository;

  @override
  Future<Result<NotificationPreferences>> call(
    NotificationPreferences preferences,
  ) => _repository.save(preferences);
}
