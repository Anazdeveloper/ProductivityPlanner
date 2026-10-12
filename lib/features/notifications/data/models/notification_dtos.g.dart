// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceRegistrationDto _$DeviceRegistrationDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DeviceRegistrationDto',
  json,
  ($checkedConvert) {
    final val = DeviceRegistrationDto(
      platform: $checkedConvert('platform', (v) => v as String),
      locale: $checkedConvert('locale', (v) => v as String),
      timeZone: $checkedConvert('time_zone', (v) => v as String),
      remindersEnabled: $checkedConvert('reminders_enabled', (v) => v as bool),
      pushToken: $checkedConvert('push_token', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'timeZone': 'time_zone',
    'remindersEnabled': 'reminders_enabled',
    'pushToken': 'push_token',
  },
);

Map<String, dynamic> _$DeviceRegistrationDtoToJson(
  DeviceRegistrationDto instance,
) => <String, dynamic>{
  'platform': instance.platform,
  'push_token': instance.pushToken,
  'locale': instance.locale,
  'time_zone': instance.timeZone,
  'reminders_enabled': instance.remindersEnabled,
};

DeviceDto _$DeviceDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeviceDto', json, ($checkedConvert) {
      final val = DeviceDto(
        id: $checkedConvert('id', (v) => v as String),
        updatedAt: $checkedConvert(
          'updated_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'updatedAt': 'updated_at'});

Map<String, dynamic> _$DeviceDtoToJson(DeviceDto instance) => <String, dynamic>{
  'id': instance.id,
  'updated_at': instance.updatedAt.toIso8601String(),
};

NotificationPreferencesDto _$NotificationPreferencesDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NotificationPreferencesDto', json, ($checkedConvert) {
  final val = NotificationPreferencesDto(
    insights: $checkedConvert('insights', (v) => v as bool),
    weeklySummary: $checkedConvert('weekly_summary', (v) => v as bool),
  );
  return val;
}, fieldKeyMap: const {'weeklySummary': 'weekly_summary'});

Map<String, dynamic> _$NotificationPreferencesDtoToJson(
  NotificationPreferencesDto instance,
) => <String, dynamic>{
  'insights': instance.insights,
  'weekly_summary': instance.weeklySummary,
};
