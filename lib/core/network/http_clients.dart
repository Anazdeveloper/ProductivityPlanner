import 'package:dio/dio.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';
import 'package:productivity_planner/core/network/interceptors/auth_interceptor.dart';
import 'package:productivity_planner/core/network/interceptors/client_headers_interceptor.dart';
import 'package:productivity_planner/core/network/interceptors/logging_interceptor.dart';

/// HTTP client without authentication: login, register, refresh, logout,
/// password reset, config. Also the retry client after a token refresh, so a
/// retry can never trigger another refresh.
///
/// Separate types (instead of two `Dio`s) make each data source's needs
/// explicit in its constructor and keep DI type-safe.
final class PublicHttpClient {
  const PublicHttpClient(this.dio);

  final Dio dio;
}

/// Authenticated HTTP client: bearer token + refresh-and-retry on 401.
final class ApiHttpClient {
  const ApiHttpClient(this.dio);

  final Dio dio;
}

/// Shared transport settings for both clients.
final class HttpClientConfig {
  const HttpClientConfig({
    required this.baseUrl,
    required this.ids,
    required this.deviceIds,
    required this.logger,
    this.adapter,
  });

  final Uri baseUrl;
  final IdGenerator ids;
  final DeviceIdProvider deviceIds;
  final AppLogger logger;

  /// Replaces the network transport (mock backend, tests).
  final HttpClientAdapter? adapter;
}

/// Interceptor order: client headers → logging.
PublicHttpClient createPublicHttpClient(HttpClientConfig config) =>
    PublicHttpClient(
      _build(config, [
        ClientHeadersInterceptor(ids: config.ids, deviceIds: config.deviceIds),
        LoggingInterceptor(config.logger),
      ]),
    );

/// Interceptor order: client headers → auth → logging (last, so it sees the
/// final headers and outcome).
///
/// The token provider usually depends on the public client (it calls
/// `auth/refresh`), which is why the two clients are built separately.
ApiHttpClient createApiHttpClient(
  HttpClientConfig config, {
  required AuthTokenProvider tokens,
  required PublicHttpClient retryClient,
}) => ApiHttpClient(
  _build(config, [
    ClientHeadersInterceptor(ids: config.ids, deviceIds: config.deviceIds),
    AuthInterceptor(tokens: tokens, retryClient: retryClient.dio),
    LoggingInterceptor(config.logger),
  ]),
);

Dio _build(HttpClientConfig config, List<Interceptor> interceptors) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _withTrailingSlash(config.baseUrl),
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json, application/problem+json'},
    ),
  );
  final adapter = config.adapter;
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.addAll(interceptors);
  return dio;
}

/// Paths are relative (`me`, `sync/push`), so the base must end in `/` for
/// `…/v1/` + `me` to resolve to `…/v1/me`.
String _withTrailingSlash(Uri baseUrl) {
  final text = baseUrl.toString();
  return text.endsWith('/') ? text : '$text/';
}
