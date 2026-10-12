import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/problem_details_dto.dart';

/// Turns a Dio error into a [Failure] following the table in
/// `contracts/api/v1.md` section 2. Unknown `code` values fall back to the
/// HTTP status, so new server codes are never breaking.
Failure mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.cancel:
      return const Failure.network();
    case DioExceptionType.badResponse:
      return mapErrorResponse(exception.response);
    case DioExceptionType.unknown:
      // No response at all is almost always a socket-level failure.
      final response = exception.response;
      return response == null
          ? const Failure.network()
          : mapErrorResponse(response);
  }
}

Failure mapErrorResponse(Response<dynamic>? response) {
  final status = response?.statusCode;
  final problem = parseProblemDetails(response?.data);
  final code = problem?.code;
  final requestId =
      problem?.requestId ?? response?.headers.value(ApiHeaders.requestId);

  if (status == null) return const Failure.network();

  switch (status) {
    case 400:
    case 422:
      return Failure.validation(
        fieldErrors: {
          for (final error in problem?.errors ?? const <ProblemFieldErrorDto>[])
            error.field: error.message,
        },
        message: problem?.detail,
      );
    case 401:
      return const Failure.unauthenticated();
    case 403:
      return _forbidden(problem);
    case 404:
      return const Failure.notFound();
    case 409:
      return Failure.conflict(
        code: code ?? 'CONFLICT',
        message: problem?.detail,
      );
    default:
      return Failure.server(
        statusCode: status,
        code: code,
        requestId: requestId,
      );
  }
}

Failure _forbidden(ProblemDetailsDto? problem) {
  final featureKey = problem?.feature;
  if (problem?.code == 'ENTITLEMENT_REQUIRED' && featureKey != null) {
    final feature = Feature.values
        .where((f) => f.key == featureKey)
        .firstOrNull;
    if (feature != null) return Failure.entitlementRequired(feature: feature);
  }
  final limitKey = problem?.limit;
  if (problem?.code == 'LIMIT_REACHED' && limitKey != null) {
    final limit = LimitKey.values.where((l) => l.key == limitKey).firstOrNull;
    if (limit != null) {
      return Failure.limitReached(limit: limit, allowed: problem?.allowed);
    }
  }
  return const Failure.forbidden();
}

/// Tolerant parser: returns null for anything that is not a problem object.
ProblemDetailsDto? parseProblemDetails(Object? data) {
  Object? decoded = data;
  if (data is String && data.isNotEmpty) {
    try {
      decoded = jsonDecode(data);
    } on FormatException {
      return null;
    }
  }
  if (decoded is! Map<String, dynamic>) return null;
  try {
    return ProblemDetailsDto.fromJson(decoded);
  } on Object {
    // A malformed error body must not hide the HTTP status.
    return null;
  }
}
