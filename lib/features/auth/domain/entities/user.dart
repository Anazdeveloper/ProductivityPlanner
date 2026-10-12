import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// The signed-in person. Holds only what the app reasons about; transport
/// details (version for If-Match, token data) stay in the data layer.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,

    /// IANA zone used for "today", reminders and analytics day boundaries.
    required String timeZone,
    required String locale,

    /// ISO weekday the week starts on: 1 = Monday … 7 = Sunday.
    @Default(1) int weekStart,
    @Default(false) bool emailVerified,
  }) = _User;
}
