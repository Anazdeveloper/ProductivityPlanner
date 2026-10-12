import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/dio_failure_mapper.dart';
import 'package:productivity_planner/core/result/result.dart';

/// Runs a remote data-source call and converts every outcome to a [Result].
/// Repositories use this so no exception crosses the data layer boundary.
///
/// - HTTP / connectivity errors become the mapped [Failure] (not reported:
///   they are expected, and the server tracks its own 5xx).
/// - A response that does not match the contract becomes
///   `Failure.server(code: 'INVALID_RESPONSE')` and is reported.
/// - Anything else is a bug: reported, returned as `Failure.unexpected`.
Future<Result<T>> guardRemoteCall<T>(
  Future<T> Function() call, {
  required ErrorReporter reporter,
}) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(mapDioException(exception));
  } on CheckedFromJsonException catch (error, stackTrace) {
    await reporter.report(
      error,
      stackTrace,
      context: {'kind': 'invalid_response', 'class': error.className},
    );
    return const Err(Failure.server(code: 'INVALID_RESPONSE'));
  } on FormatException catch (error, stackTrace) {
    await reporter.report(error, stackTrace, context: {'kind': 'invalid_response'});
    return const Err(Failure.server(code: 'INVALID_RESPONSE'));
  } on Object catch (error, stackTrace) {
    await reporter.report(error, stackTrace);
    return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
  }
}
