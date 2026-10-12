import 'dart:developer' as developer;

import 'package:productivity_planner/core/logging/log_redactor.dart';

enum LogLevel { debug, info, warning, error }

/// App-wide logger. Messages must never contain user content (task titles,
/// notes, transcripts, emails); put identifiers in [context] instead, which
/// is redacted as a safety net.
abstract interface class AppLogger {
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context,
  });
}

extension AppLoggerLevels on AppLogger {
  void debug(String message, {Map<String, Object?> context = const {}}) =>
      log(LogLevel.debug, message, context: context);

  void info(String message, {Map<String, Object?> context = const {}}) =>
      log(LogLevel.info, message, context: context);

  void warning(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => log(
    LogLevel.warning,
    message,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => log(
    LogLevel.error,
    message,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );
}

/// Writes to the platform log via `dart:developer` (visible in DevTools,
/// `flutter logs`, Xcode and logcat). No package needed.
final class DeveloperLogger implements AppLogger {
  DeveloperLogger({this.minLevel = LogLevel.debug, this.name = 'planner'});

  final LogLevel minLevel;
  final String name;

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    if (level.index < minLevel.index) return;
    final safeContext = redactLogContext(context);
    final line = safeContext.isEmpty ? message : '$message $safeContext';
    developer.log(
      line,
      name: name,
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Matches package:logging values so DevTools colours levels correctly.
  static int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
