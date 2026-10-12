// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'display_name': instance.displayName,
      'time_zone': instance.timeZone,
      'locale': instance.locale,
    };

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

Map<String, dynamic> _$AppleSignInRequestDtoToJson(
  AppleSignInRequestDto instance,
) => <String, dynamic>{
  'id_token': instance.idToken,
  'raw_nonce': instance.rawNonce,
  'authorization_code': ?instance.authorizationCode,
  'display_name': ?instance.displayName,
  'time_zone': instance.timeZone,
  'locale': instance.locale,
};

Map<String, dynamic> _$GoogleSignInRequestDtoToJson(
  GoogleSignInRequestDto instance,
) => <String, dynamic>{
  'id_token': instance.idToken,
  'time_zone': instance.timeZone,
  'locale': instance.locale,
};

Map<String, dynamic> _$PasswordResetRequestDtoToJson(
  PasswordResetRequestDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'code': instance.code,
  'new_password': instance.newPassword,
};

Map<String, dynamic> _$UpdateProfileRequestDtoToJson(
  UpdateProfileRequestDto instance,
) => <String, dynamic>{'display_name': ?instance.displayName};

_TokenPairDto _$TokenPairDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TokenPairDto',
      json,
      ($checkedConvert) {
        final val = _TokenPairDto(
          accessToken: $checkedConvert('access_token', (v) => v as String),
          accessTokenExpiresAt: $checkedConvert(
            'access_token_expires_at',
            (v) => DateTime.parse(v as String),
          ),
          refreshToken: $checkedConvert('refresh_token', (v) => v as String),
          refreshTokenExpiresAt: $checkedConvert(
            'refresh_token_expires_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'accessToken': 'access_token',
        'accessTokenExpiresAt': 'access_token_expires_at',
        'refreshToken': 'refresh_token',
        'refreshTokenExpiresAt': 'refresh_token_expires_at',
      },
    );

Map<String, dynamic> _$TokenPairDtoToJson(
  _TokenPairDto instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'access_token_expires_at': instance.accessTokenExpiresAt.toIso8601String(),
  'refresh_token': instance.refreshToken,
  'refresh_token_expires_at': instance.refreshTokenExpiresAt.toIso8601String(),
};

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_UserDto',
  json,
  ($checkedConvert) {
    final val = _UserDto(
      id: $checkedConvert('id', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String),
      displayName: $checkedConvert('display_name', (v) => v as String),
      timeZone: $checkedConvert('time_zone', (v) => v as String),
      locale: $checkedConvert('locale', (v) => v as String),
      weekStart: $checkedConvert(
        'week_start',
        (v) => (v as num?)?.toInt() ?? 1,
      ),
      emailVerified: $checkedConvert(
        'email_verified',
        (v) => v as bool? ?? false,
      ),
      version: $checkedConvert('version', (v) => (v as num?)?.toInt() ?? 1),
    );
    return val;
  },
  fieldKeyMap: const {
    'displayName': 'display_name',
    'timeZone': 'time_zone',
    'weekStart': 'week_start',
    'emailVerified': 'email_verified',
  },
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'display_name': instance.displayName,
  'time_zone': instance.timeZone,
  'locale': instance.locale,
  'week_start': instance.weekStart,
  'email_verified': instance.emailVerified,
  'version': instance.version,
};

_AuthResultDto _$AuthResultDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AuthResultDto', json, ($checkedConvert) {
      final val = _AuthResultDto(
        tokens: $checkedConvert(
          'tokens',
          (v) => TokenPairDto.fromJson(v as Map<String, dynamic>),
        ),
        user: $checkedConvert(
          'user',
          (v) => UserDto.fromJson(v as Map<String, dynamic>),
        ),
        isNewUser: $checkedConvert('is_new_user', (v) => v as bool? ?? false),
      );
      return val;
    }, fieldKeyMap: const {'isNewUser': 'is_new_user'});

Map<String, dynamic> _$AuthResultDtoToJson(_AuthResultDto instance) =>
    <String, dynamic>{
      'tokens': instance.tokens.toJson(),
      'user': instance.user.toJson(),
      'is_new_user': instance.isNewUser,
    };

_StoredSessionDto _$StoredSessionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_StoredSessionDto', json, ($checkedConvert) {
      final val = _StoredSessionDto(
        tokens: $checkedConvert(
          'tokens',
          (v) => TokenPairDto.fromJson(v as Map<String, dynamic>),
        ),
        user: $checkedConvert(
          'user',
          (v) => UserDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$StoredSessionDtoToJson(_StoredSessionDto instance) =>
    <String, dynamic>{
      'tokens': instance.tokens.toJson(),
      'user': instance.user.toJson(),
    };
