import 'package:freezed_annotation/freezed_annotation.dart';

part 'problem_details_dto.freezed.dart';
part 'problem_details_dto.g.dart';

/// RFC 9457 error body (`application/problem+json`) as defined in
/// `contracts/api/v1.md` section 2. Every field is optional so a malformed
/// error body never hides the HTTP status.
@freezed
abstract class ProblemDetailsDto with _$ProblemDetailsDto {
  const factory ProblemDetailsDto({
    String? type,
    String? title,
    int? status,
    String? detail,
    String? code,
    String? requestId,
    @Default(<ProblemFieldErrorDto>[]) List<ProblemFieldErrorDto> errors,
    // Present with ENTITLEMENT_REQUIRED.
    String? feature,
    // Present with LIMIT_REACHED.
    String? limit,
    int? allowed,
  }) = _ProblemDetailsDto;

  factory ProblemDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ProblemDetailsDtoFromJson(json);
}

@freezed
abstract class ProblemFieldErrorDto with _$ProblemFieldErrorDto {
  const factory ProblemFieldErrorDto({
    required String field,
    required String message,
  }) = _ProblemFieldErrorDto;

  factory ProblemFieldErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ProblemFieldErrorDtoFromJson(json);
}
