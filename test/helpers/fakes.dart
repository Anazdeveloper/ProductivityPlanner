import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';
import 'package:productivity_planner/core/time/clock.dart';

final class FixedClock implements Clock {
  FixedClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;
}

/// Produces `id-1`, `id-2`, …
final class SequentialIdGenerator implements IdGenerator {
  int _next = 1;

  @override
  String newId() => 'id-${_next++}';
}

final class FixedDeviceIdProvider implements DeviceIdProvider {
  const FixedDeviceIdProvider([this.id = 'device-1']);

  final String id;

  @override
  Future<String> deviceId() async => id;
}

final class LogEntry {
  const LogEntry(this.level, this.message, this.context);

  final LogLevel level;
  final String message;
  final Map<String, Object?> context;
}

final class RecordingLogger implements AppLogger {
  final List<LogEntry> entries = [];

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => entries.add(LogEntry(level, message, context));
}

final class RecordingErrorReporter implements ErrorReporter {
  final List<Object> errors = [];

  @override
  Future<void> report(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    Map<String, Object?> context = const {},
  }) async => errors.add(error);
}

/// Scriptable token provider for interceptor tests.
final class FakeTokenProvider implements AuthTokenProvider {
  FakeTokenProvider({required this.onRefresh, this.token});

  String? token;
  final TokenRefreshResult Function() onRefresh;
  int refreshCalls = 0;
  int sessionExpiredCalls = 0;

  @override
  Future<String?> accessToken() async => token;

  @override
  Future<TokenRefreshResult> refresh() async {
    refreshCalls++;
    final result = onRefresh();
    if (result case TokenRefreshed(:final accessToken)) token = accessToken;
    return result;
  }

  @override
  Future<void> onSessionExpired() async {
    sessionExpiredCalls++;
    token = null;
  }
}

final class FakeDeviceContext implements DeviceContext {
  const FakeDeviceContext({this.zone = 'Asia/Kolkata', this.locale = 'en-IN'});

  final String zone;
  final String locale;

  @override
  Future<String> timeZone() async => zone;

  @override
  String localeTag() => locale;
}
