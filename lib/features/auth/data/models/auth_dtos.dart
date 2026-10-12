import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

// Response shapes from contracts/api/v1.md §3.1. Keys are snake_case via
// build.yaml (`field_rename: snake`).

@freezed
abstract class TokenPairDto with _$TokenPairDto {
  const factory TokenPairDto({
    required String accessToken,
    required DateTime accessTokenExpiresAt,
    required String refreshToken,
    required DateTime refreshTokenExpiresAt,
  }) = _TokenPairDto;

  factory TokenPairDto.fromJson(Map<String, dynamic> json) =>
      _$TokenPairDtoFromJson(json);
}

@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String displayName,
    required String timeZone,
    required String locale,
    @Default(1) int weekStart,
    @Default(false) bool emailVerified,
    @Default(1) int version,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
abstract class AuthResultDto with _$AuthResultDto {
  const factory AuthResultDto({
    required TokenPairDto tokens,
    required UserDto user,
    @Default(false) bool isNewUser,
  }) = _AuthResultDto;

  factory AuthResultDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResultDtoFromJson(json);
}

/// What is persisted in secure storage: enough to start offline.
@freezed
abstract class StoredSessionDto with _$StoredSessionDto {
  const factory StoredSessionDto({
    required TokenPairDto tokens,
    required UserDto user,
  }) = _StoredSessionDto;

  factory StoredSessionDto.fromJson(Map<String, dynamic> json) =>
      _$StoredSessionDtoFromJson(json);
}

// Request bodies: serialise only.

@JsonSerializable(createFactory: false)
final class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.displayName,
    required this.timeZone,
    required this.locale,
  });

  final String email;
  final String password;
  final String displayName;
  final String timeZone;
  final String locale;

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class LoginRequestDto {
  const LoginRequestDto({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class AppleSignInRequestDto {
  const AppleSignInRequestDto({
    required this.idToken,
    required this.rawNonce,
    required this.timeZone,
    required this.locale,
    this.authorizationCode,
    this.displayName,
  });

  final String idToken;
  final String rawNonce;
  final String? authorizationCode;
  final String? displayName;
  final String timeZone;
  final String locale;

  Map<String, dynamic> toJson() => _$AppleSignInRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class GoogleSignInRequestDto {
  const GoogleSignInRequestDto({
    required this.idToken,
    required this.timeZone,
    required this.locale,
  });

  final String idToken;
  final String timeZone;
  final String locale;

  Map<String, dynamic> toJson() => _$GoogleSignInRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class PasswordResetRequestDto {
  const PasswordResetRequestDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;

  Map<String, dynamic> toJson() => _$PasswordResetRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
final class UpdateProfileRequestDto {
  const UpdateProfileRequestDto({this.displayName});

  final String? displayName;

  Map<String, dynamic> toJson() => _$UpdateProfileRequestDtoToJson(this);
}
