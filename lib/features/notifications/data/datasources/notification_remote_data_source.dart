import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_dtos.dart';

/// Device and notification-preference endpoints. Throws; repositories
/// guard with `guardRemoteCall`.
abstract interface class NotificationRemoteDataSource {
  Future<DeviceDto> putDevice(String deviceId, DeviceRegistrationDto body);

  Future<NotificationPreferencesDto> getPreferences();

  Future<NotificationPreferencesDto> putPreferences(
    NotificationPreferencesDto body,
  );
}

final class HttpNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  const HttpNotificationRemoteDataSource(this._client);

  final ApiHttpClient _client;

  @override
  Future<DeviceDto> putDevice(
    String deviceId,
    DeviceRegistrationDto body,
  ) async {
    final response = await _client.dio.put<Map<String, dynamic>>(
      ApiPaths.device(deviceId),
      data: body.toJson(),
    );
    return DeviceDto.fromJson(_body(response.data));
  }

  @override
  Future<NotificationPreferencesDto> getPreferences() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.meNotificationPreferences,
    );
    return NotificationPreferencesDto.fromJson(_body(response.data));
  }

  @override
  Future<NotificationPreferencesDto> putPreferences(
    NotificationPreferencesDto body,
  ) async {
    final response = await _client.dio.put<Map<String, dynamic>>(
      ApiPaths.meNotificationPreferences,
      data: body.toJson(),
    );
    return NotificationPreferencesDto.fromJson(_body(response.data));
  }
}

Map<String, dynamic> _body(Map<String, dynamic>? data) =>
    data ?? (throw const FormatException('Expected a JSON object body'));
