import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/interceptors/auth_interceptor.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/network/remote_call.dart';
import 'package:productivity_planner/core/result/result.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockApiAdapter adapter;
  late FakeTokenProvider tokens;
  late RecordingLogger logger;
  late PublicHttpClient public;
  late ApiHttpClient api;

  void build({
    String? token = 'old',
    TokenRefreshResult Function()? onRefresh,
  }) {
    adapter = MockApiAdapter();
    tokens = FakeTokenProvider(
      token: token,
      onRefresh: onRefresh ?? () => const TokenRefreshed('new'),
    );
    logger = RecordingLogger();
    final config = HttpClientConfig(
      baseUrl: Uri.parse('https://api.test/v1'),
      ids: SequentialIdGenerator(),
      deviceIds: const FixedDeviceIdProvider(),
      logger: logger,
      adapter: adapter,
    );
    public = createPublicHttpClient(config);
    api = createApiHttpClient(config, tokens: tokens, retryClient: public);
  }

  /// `me` succeeds only with the given token, otherwise 401.
  void meRequiresToken(String validToken) {
    adapter.on('GET', 'me', (request) {
      final auth = request.headers[ApiHeaders.authorization];
      return auth == 'Bearer $validToken'
          ? MockResponse.json({'id': 'u1'})
          : MockResponse.problem(status: 401, code: 'TOKEN_EXPIRED');
    });
  }

  test('relative paths resolve under /v1/ and client headers are sent', () async {
    build();
    meRequiresToken('old');

    final response = await api.dio.get<Map<String, dynamic>>(ApiPaths.me);

    expect(response.data, {'id': 'u1'});
    final request = adapter.received.single;
    expect(request.path, 'me');
    expect(request.headers[ApiHeaders.requestId], 'id-1');
    expect(request.headers[ApiHeaders.deviceId], 'device-1');
    expect(request.headers[ApiHeaders.authorization], 'Bearer old');
  });

  test('401 → one refresh → retried with the new token and same request id', () async {
    build();
    meRequiresToken('new');

    final response = await api.dio.get<Map<String, dynamic>>(ApiPaths.me);

    expect(response.statusCode, 200);
    expect(tokens.refreshCalls, 1);
    expect(adapter.received, hasLength(2));
    expect(
      adapter.received.last.headers[ApiHeaders.requestId],
      adapter.received.first.headers[ApiHeaders.requestId],
    );
  });

  test('concurrent 401s trigger a single refresh', () async {
    build();
    meRequiresToken('new');

    final results = await Future.wait([
      api.dio.get<dynamic>(ApiPaths.me),
      api.dio.get<dynamic>(ApiPaths.me),
      api.dio.get<dynamic>(ApiPaths.me),
    ]);

    expect(results.map((r) => r.statusCode), everyElement(200));
    expect(tokens.refreshCalls, 1);
  });

  test('rejected refresh ends the session and surfaces unauthenticated', () async {
    build(onRefresh: () => const TokenRefreshRejected());
    meRequiresToken('never-valid');

    final result = await guardRemoteCall(
      () => api.dio.get<dynamic>(ApiPaths.me),
      reporter: RecordingErrorReporter(),
    );

    expect(result, const Err<Response<dynamic>>(Failure.unauthenticated()));
    expect(tokens.sessionExpiredCalls, 1);
  });

  test('refresh unavailable keeps the session and surfaces network', () async {
    build(onRefresh: () => const TokenRefreshUnavailable());
    meRequiresToken('never-valid');

    final result = await guardRemoteCall(
      () => api.dio.get<dynamic>(ApiPaths.me),
      reporter: RecordingErrorReporter(),
    );

    expect(result, const Err<Response<dynamic>>(Failure.network()));
    expect(tokens.sessionExpiredCalls, 0);
    expect(tokens.token, 'old');
  });

  test('a retried request that is still 401 does not refresh again', () async {
    build();
    meRequiresToken('never-valid');

    final result = await guardRemoteCall(
      () => api.dio.get<dynamic>(ApiPaths.me),
      reporter: RecordingErrorReporter(),
    );

    expect(result, const Err<Response<dynamic>>(Failure.unauthenticated()));
    expect(tokens.refreshCalls, 1);
  });

  test('skipAuth requests carry no token and are not refreshed', () async {
    build();
    adapter.on(
      'POST',
      'auth/login',
      (_) => MockResponse.problem(status: 401, code: 'UNAUTHENTICATED'),
    );

    final result = await guardRemoteCall(
      () => api.dio.post<dynamic>(
        ApiPaths.authLogin,
        options: Options(extra: {AuthInterceptor.skipAuth: true}),
      ),
      reporter: RecordingErrorReporter(),
    );

    expect(result.failureOrNull, const Failure.unauthenticated());
    expect(adapter.received.single.headers[ApiHeaders.authorization], isNull);
    expect(tokens.refreshCalls, 0);
  });

  test('offline adapter → network failure', () async {
    build();
    adapter.offline = true;

    final result = await guardRemoteCall(
      () => api.dio.get<dynamic>(ApiPaths.me),
      reporter: RecordingErrorReporter(),
    );

    expect(result.failureOrNull, const Failure.network());
  });

  test('unregistered mock routes fail loudly as 404', () async {
    build();
    final result = await guardRemoteCall(
      () => public.dio.get<dynamic>('nope'),
      reporter: RecordingErrorReporter(),
    );
    expect(result.failureOrNull, const Failure.notFound());
  });

  test('POST requests carry an idempotency key, kept on retry', () async {
    build();
    var calls = 0;
    adapter.on('POST', 'sync/push', (request) {
      calls++;
      return calls == 1
          ? MockResponse.problem(status: 401, code: 'TOKEN_EXPIRED')
          : MockResponse.json({'results': <Object>[]});
    });

    await api.dio.post<dynamic>(ApiPaths.syncPush, data: {'ops': <Object>[]});

    final keys = adapter.received
        .map((r) => r.headers[ApiHeaders.idempotencyKey])
        .toList();
    expect(keys, hasLength(2));
    expect(keys.first, isNotNull);
    expect(keys.last, keys.first);
  });

  test('a caller-supplied idempotency key is not replaced', () async {
    build();
    adapter.on('POST', 'sync/push', (_) => MockResponse.json({}));

    await api.dio.post<dynamic>(
      ApiPaths.syncPush,
      options: Options(headers: {ApiHeaders.idempotencyKey: 'op-1'}),
    );

    expect(adapter.received.single.headers[ApiHeaders.idempotencyKey], 'op-1');
  });

  test('path parameters are captured', () async {
    build();
    adapter.on(
      'POST',
      'occurrences/:id/complete',
      (request) => MockResponse.json({'id': request.pathParameters['id']}),
    );

    final response = await api.dio.post<Map<String, dynamic>>(
      ApiPaths.occurrenceCommand('abc', OccurrenceCommand.complete),
    );

    expect(response.data, {'id': 'abc'});
  });

  test('logs never contain headers or bodies', () async {
    build();
    meRequiresToken('old');

    await api.dio.get<dynamic>(ApiPaths.me);

    final logged = logger.entries.map((e) => e.context.toString()).join();
    expect(logged, isNot(contains('Bearer')));
    expect(logged, contains('/v1/me'));
  });

  test('invalid response shapes are reported and mapped to server', () async {
    final reporter = RecordingErrorReporter();
    final result = await guardRemoteCall<int>(
      () async => throw const FormatException('bad json'),
      reporter: reporter,
    );
    expect(result.failureOrNull, const Failure.server(code: 'INVALID_RESPONSE'));
    expect(reporter.errors, hasLength(1));
  });
}
