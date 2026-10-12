import 'package:flutter/foundation.dart';
import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/remote_call.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_dtos.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';

final class DeviceRegistrationRepositoryImpl
    implements DeviceRegistrationRepository {
  DeviceRegistrationRepositoryImpl({
    required NotificationRemoteDataSource remote,
    required DeviceIdProvider deviceIds,
    required DeviceContext device,
    required ErrorReporter reporter,
    TargetPlatform? platform,
  }) : _remote = remote,
       _deviceIds = deviceIds,
       _device = device,
       _reporter = reporter,
       _platform = platform ?? defaultTargetPlatform;

  final NotificationRemoteDataSource _remote;
  final DeviceIdProvider _deviceIds;
  final DeviceContext _device;
  final ErrorReporter _reporter;
  final TargetPlatform _platform;

  @override
  Future<Result<Unit>> register({
    required String? pushToken,
    required bool remindersEnabled,
  }) => guardRemoteCall(() async {
    await _remote.putDevice(
      await _deviceIds.deviceId(),
      DeviceRegistrationDto(
        platform: _platform == TargetPlatform.iOS ? 'ios' : 'android',
        pushToken: pushToken,
        locale: _device.localeTag(),
        timeZone: await _device.timeZone(),
        remindersEnabled: remindersEnabled,
      ),
    );
    return unit;
  }, reporter: _reporter);
}

final class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  const NotificationPreferencesRepositoryImpl({
    required NotificationRemoteDataSource remote,
    required ErrorReporter reporter,
  }) : _remote = remote,
       _reporter = reporter;

  final NotificationRemoteDataSource _remote;
  final ErrorReporter _reporter;

  @override
  Future<Result<NotificationPreferences>> load() => guardRemoteCall(
    () async => (await _remote.getPreferences()).toDomain(),
    reporter: _reporter,
  );

  @override
  Future<Result<NotificationPreferences>> save(
    NotificationPreferences preferences,
  ) => guardRemoteCall(
    () async => (await _remote.putPreferences(
      NotificationPreferencesDto.fromDomain(preferences),
    )).toDomain(),
    reporter: _reporter,
  );
}
