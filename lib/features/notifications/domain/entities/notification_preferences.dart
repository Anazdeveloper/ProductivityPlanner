import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences.freezed.dart';

/// Server-sent push categories the user may turn off (contract §3.2).
/// Account, security and subscription messages are always delivered.
@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default(true) bool insights,
    @Default(true) bool weeklySummary,
  }) = _NotificationPreferences;
}
