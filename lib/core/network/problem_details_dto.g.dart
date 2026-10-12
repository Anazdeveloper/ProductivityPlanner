// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'problem_details_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProblemDetailsDto _$ProblemDetailsDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ProblemDetailsDto', json, ($checkedConvert) {
      final val = _ProblemDetailsDto(
        type: $checkedConvert('type', (v) => v as String?),
        title: $checkedConvert('title', (v) => v as String?),
        status: $checkedConvert('status', (v) => (v as num?)?.toInt()),
        detail: $checkedConvert('detail', (v) => v as String?),
        code: $checkedConvert('code', (v) => v as String?),
        requestId: $checkedConvert('request_id', (v) => v as String?),
        errors: $checkedConvert(
          'errors',
          (v) =>
              (v as List<dynamic>?)
                  ?.map(
                    (e) => ProblemFieldErrorDto.fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList() ??
              const <ProblemFieldErrorDto>[],
        ),
        feature: $checkedConvert('feature', (v) => v as String?),
        limit: $checkedConvert('limit', (v) => v as String?),
        allowed: $checkedConvert('allowed', (v) => (v as num?)?.toInt()),
      );
      return val;
    }, fieldKeyMap: const {'requestId': 'request_id'});

Map<String, dynamic> _$ProblemDetailsDtoToJson(_ProblemDetailsDto instance) =>
    <String, dynamic>{
      'type': ?instance.type,
      'title': ?instance.title,
      'status': ?instance.status,
      'detail': ?instance.detail,
      'code': ?instance.code,
      'request_id': ?instance.requestId,
      'errors': instance.errors.map((e) => e.toJson()).toList(),
      'feature': ?instance.feature,
      'limit': ?instance.limit,
      'allowed': ?instance.allowed,
    };

_ProblemFieldErrorDto _$ProblemFieldErrorDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ProblemFieldErrorDto', json, ($checkedConvert) {
  final val = _ProblemFieldErrorDto(
    field: $checkedConvert('field', (v) => v as String),
    message: $checkedConvert('message', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ProblemFieldErrorDtoToJson(
  _ProblemFieldErrorDto instance,
) => <String, dynamic>{'field': instance.field, 'message': instance.message};
