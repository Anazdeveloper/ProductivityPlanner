import 'package:json_annotation/json_annotation.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';

part 'notification_dtos.g.dart';

/// `PUT devices/{id}` body (contract §3.2).
@JsonSerializable()
class DeviceRegistrationDto {
  const DeviceRegistrationDto({
    required this.platform,
    required this.locale,
    required this.timeZone,
    required this.remindersEnabled,
    this.pushToken,
  });

  factory DeviceRegistrationDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceRegistrationDtoFromJson(json);

  /// `ios` or `android`.
  final String platform;

  /// Sent explicitly as `null` when push is unavailable, so the server
  /// clears a stale token.
  @JsonKey(includeIfNull: true)
  final String? pushToken;
  final String locale;
  final String timeZone;
  final bool remindersEnabled;

  Map<String, dynamic> toJson() => _$DeviceRegistrationDtoToJson(this);
}

/// `PUT devices/{id}` response.
@JsonSerializable()
class DeviceDto {
  const DeviceDto({required this.id, required this.updatedAt});

  factory DeviceDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceDtoFromJson(json);

  final String id;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => _$DeviceDtoToJson(this);
}

/// `me/notification-preferences` body, both directions.
@JsonSerializable()
class NotificationPreferencesDto {
  const NotificationPreferencesDto({
    required this.insights,
    required this.weeklySummary,
  });

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesDtoFromJson(json);

  factory NotificationPreferencesDto.fromDomain(NotificationPreferences p) =>
      NotificationPreferencesDto(
        insights: p.insights,
        weeklySummary: p.weeklySummary,
      );

  final bool insights;
  final bool weeklySummary;

  NotificationPreferences toDomain() =>
      NotificationPreferences(insights: insights, weeklySummary: weeklySummary);

  Map<String, dynamic> toJson() => _$NotificationPreferencesDtoToJson(this);
}
