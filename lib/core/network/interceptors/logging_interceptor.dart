import 'package:dio/dio.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/dio_failure_mapper.dart';

/// Logs method, path, status, duration and request id; for an error, the
/// problem `code` and the names of rejected fields (never their values).
/// Never logs headers, query strings or bodies: they carry tokens and task
/// text.
final class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  static const _startedKey = 'log.stopwatch';

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedKey] = Stopwatch()..start();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug('http', context: _context(response.requestOptions, response.statusCode));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final problem = parseProblemDetails(err.response?.data);
    final context = {
      ..._context(err.requestOptions, status),
      'error': err.type.name,
      if (problem?.code case final code?) 'code': code,
      if (problem != null && problem.errors.isNotEmpty)
        'fields': [for (final e in problem.errors) '${e.field}: ${e.message}'],
    };
    if (status != null && status < 500) {
      _logger.info('http', context: context);
    } else {
      _logger.warning('http', context: context);
    }
    handler.next(err);
  }

  Map<String, Object?> _context(RequestOptions options, int? status) {
    final stopwatch = switch (options.extra[_startedKey]) {
      final Stopwatch watch => watch,
      _ => null,
    };
    return {
      'method': options.method,
      'path': options.uri.path,
      'status': status,
      'ms': stopwatch?.elapsedMilliseconds,
      'request_id': options.headers[ApiHeaders.requestId],
    };
  }
}
