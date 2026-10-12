import 'package:productivity_planner/core/logging/app_logger.dart';

/// Sends unexpected errors to error tracking. Phase 13 adds a Sentry
/// implementation with the same PII scrubbing; callers do not change.
abstract interface class ErrorReporter {
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    bool fatal,
    Map<String, Object?> context,
  });
}

/// Development / pre-Sentry implementation: writes to the app log.
final class LoggingErrorReporter implements ErrorReporter {
  const LoggingErrorReporter(this._logger);

  final AppLogger _logger;

  @override
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    Map<String, Object?> context = const {},
  }) async {
    _logger.error(
      fatal ? 'Fatal error' : 'Unexpected error',
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }
}
