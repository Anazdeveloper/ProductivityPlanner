import 'package:dio/dio.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';

/// Attaches the access token and recovers from `401` with one refresh.
///
/// - [QueuedInterceptor] serialises error handling, so when several requests
///   fail with 401 at once only the first refreshes; the rest see that the
///   token changed since they were sent and simply retry.
/// - Retries go through [_retryClient], which has no auth interceptor.
///   Retrying through the same client from inside a queued interceptor would
///   deadlock, and a second 401 must not trigger another refresh.
/// - A refresh that fails for connectivity reasons keeps the session and
///   surfaces as a network error; only a rejected refresh ends the session.
///
/// Requests can opt out with `Options(extra: {AuthInterceptor.skipAuth: true})`
/// (login, register, refresh, config).
final class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required AuthTokenProvider tokens,
    required Dio retryClient,
  }) : _tokens = tokens,
       _retryClient = retryClient;

  static const skipAuth = 'auth.skip';
  static const _tokenUsed = 'auth.tokenUsed';
  static const _retried = 'auth.retried';

  final AuthTokenProvider _tokens;
  final Dio _retryClient;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuth] != true) {
      final token = await _tokens.accessToken();
      if (token != null) {
        options.headers[ApiHeaders.authorization] = 'Bearer $token';
        options.extra[_tokenUsed] = token;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    if (!isUnauthorized ||
        options.extra[skipAuth] == true ||
        options.extra[_retried] == true) {
      handler.next(err);
      return;
    }

    final usedToken = switch (options.extra[_tokenUsed]) {
      final String token => token,
      _ => null,
    };
    final currentToken = await _tokens.accessToken();

    final String freshToken;
    if (currentToken != null && currentToken != usedToken) {
      // Another request already refreshed while this one was in flight.
      freshToken = currentToken;
    } else {
      switch (await _tokens.refresh()) {
        case TokenRefreshed(:final accessToken):
          freshToken = accessToken;
        case TokenRefreshRejected():
          await _tokens.onSessionExpired();
          handler.next(err);
          return;
        case TokenRefreshUnavailable():
          handler.next(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
              message: 'Token refresh unavailable',
            ),
          );
          return;
      }
    }

    try {
      final response = await _retryClient.fetch<dynamic>(
        options.copyWith(
          headers: {
            ...options.headers,
            ApiHeaders.authorization: 'Bearer $freshToken',
          },
          extra: {...options.extra, _retried: true, _tokenUsed: freshToken},
        ),
      );
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
