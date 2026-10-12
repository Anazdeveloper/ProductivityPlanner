import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/features/auth/data/datasources/account_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/session_storage.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/fake_credential_sources.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/nonce_generator.dart';
import 'package:productivity_planner/features/auth/data/mock/auth_mock_routes.dart';
import 'package:productivity_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:productivity_planner/features/auth/data/repositories/auth_session_manager.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';

import '../../../helpers/fakes.dart';

/// Repository → session manager → real Dio clients + interceptors →
/// MockApiAdapter running the contract's auth endpoints.
void main() {
  late FixedClock clock;
  late MockApiAdapter adapter;
  late AuthMockBackend backend;
  late InMemorySessionStorage storage;
  late FakeAppleCredentialSource apple;
  late FakeGoogleCredentialSource google;
  late PublicHttpClient public;
  late AuthRepositoryImpl repository;

  /// Simulates an app (re)launch on top of the same storage and backend.
  AuthRepositoryImpl launchApp() {
    final logger = RecordingLogger();
    final reporter = RecordingErrorReporter();
    final config = HttpClientConfig(
      baseUrl: Uri.parse('https://api.test/v1'),
      ids: SequentialIdGenerator(),
      deviceIds: const FixedDeviceIdProvider(),
      logger: logger,
      adapter: adapter,
    );
    public = createPublicHttpClient(config);
    final authRemote = HttpAuthRemoteDataSource(public);
    final session = AuthSessionManager(
      storage: storage,
      remote: authRemote,
      clock: clock,
      logger: logger,
      reporter: reporter,
    );
    final api = createApiHttpClient(config, tokens: session, retryClient: public);
    return AuthRepositoryImpl(
      session: session,
      authRemote: authRemote,
      accountRemote: HttpAccountRemoteDataSource(api),
      apple: apple,
      google: google,
      nonces: NonceGenerator(),
      device: const FakeDeviceContext(),
      reporter: reporter,
    );
  }

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 6, 9));
    adapter = MockApiAdapter();
    backend = AuthMockBackend(clock: clock, ids: SequentialIdGenerator())
      ..register(adapter);
    storage = InMemorySessionStorage();
    apple = FakeAppleCredentialSource();
    google = FakeGoogleCredentialSource();
    repository = launchApp();
  });

  Future<void> signInDemo() async {
    final result = await repository.signInWithEmail(
      email: 'demo@example.com',
      password: 'password123',
    );
    expect(result.isOk, isTrue, reason: '$result');
  }

  group('sign-in', () {
    test('success persists the session and emits authenticated', () async {
      final states = <AuthState>[];
      final sub = repository.watchAuthState().listen(states.add);

      await signInDemo();
      await Future<void>.delayed(Duration.zero);

      expect(repository.currentState, isA<Authenticated>());
      expect(states.last, isA<Authenticated>());
      final stored = await storage.read();
      expect(stored?.user.email, 'demo@example.com');
      expect(stored?.tokens.refreshToken, startsWith('refresh-'));
      await sub.cancel();
    });

    test('wrong password → invalidCredentials, nothing stored', () async {
      final result = await repository.signInWithEmail(
        email: 'demo@example.com',
        password: 'wrong-password',
      );
      expect(result.failureOrNull, const Failure.invalidCredentials());
      expect(await storage.read(), isNull);
    });

    test('offline → network failure', () async {
      adapter.offline = true;
      final result = await repository.signInWithEmail(
        email: 'demo@example.com',
        password: 'password123',
      );
      expect(result.failureOrNull, const Failure.network());
    });

    test('registration sends device time zone and locale', () async {
      final result = await repository.registerWithEmail(
        email: 'new@example.com',
        password: 'long-enough-pw',
        displayName: 'New Person',
      );
      expect(result.valueOrNull?.timeZone, 'Asia/Kolkata');
      expect(result.valueOrNull?.locale, 'en-IN');
    });

    test('registering a taken email → conflict EMAIL_TAKEN', () async {
      final result = await repository.registerWithEmail(
        email: 'demo@example.com',
        password: 'long-enough-pw',
        displayName: 'Dup',
      );
      expect(result.failureOrNull, const Failure.conflict(code: 'EMAIL_TAKEN'));
    });

    test('Apple: hashed nonce to Apple, raw nonce to the server', () async {
      final result = await repository.signInWithApple();
      expect(result.valueOrNull?.displayName, 'Apple Tester');

      final body = adapter.received.last.body as Map<String, dynamic>;
      final rawNonce = body['raw_nonce'] as String;
      expect(rawNonce, isNotEmpty);
      expect(apple.lastHashedNonce, NonceGenerator().sha256Hex(rawNonce));
    });

    test('cancelling the provider sheet → cancelled, no request', () async {
      google.cancel = true;
      final result = await repository.signInWithGoogle();
      expect(result.failureOrNull, const Failure.cancelled());
      expect(adapter.received, isEmpty);
    });
  });

  group('restore (offline-first)', () {
    test('a stored session restores as signed in without the network', () async {
      await signInDemo();
      adapter.offline = true;

      final relaunched = launchApp();
      final result = await relaunched.restoreSession();

      expect(result.valueOrNull, isA<Authenticated>());
    });

    test('an expired refresh token restores as sessionExpired', () async {
      await signInDemo();
      clock.current = clock.current.add(const Duration(days: 61));

      final relaunched = launchApp();
      final state = (await relaunched.restoreSession()).valueOrNull;

      expect(
        state,
        const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
      );
      expect(await storage.read(), isNull);
    });

    test('nothing stored → unauthenticated', () async {
      final state = (await repository.restoreSession()).valueOrNull;
      expect(state, const AuthState.unauthenticated());
    });
  });

  group('token refresh', () {
    test('expired access token is refreshed transparently and rotated', () async {
      await signInDemo();
      final before = (await storage.read())?.tokens;
      clock.current = clock.current.add(const Duration(minutes: 16));

      final result = await repository.refreshCurrentUser();

      expect(result.isOk, isTrue, reason: '$result');
      final after = (await storage.read())?.tokens;
      expect(after?.refreshToken, isNot(before?.refreshToken));
      expect(after?.accessToken, isNot(before?.accessToken));
    });

    test('reused refresh token ends the session as sessionExpired', () async {
      await signInDemo();
      final leaked = (await storage.read())?.tokens.refreshToken ?? '';
      // Someone else uses the token first (theft scenario).
      await public.dio.post<dynamic>(
        ApiPaths.authRefresh,
        data: {'refresh_token': leaked},
      );
      clock.current = clock.current.add(const Duration(minutes: 16));

      final result = await repository.refreshCurrentUser();

      expect(result.failureOrNull, const Failure.unauthenticated());
      expect(
        repository.currentState,
        const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
      );
      expect(await storage.read(), isNull);
    });

    test('refresh while offline keeps the session', () async {
      await signInDemo();
      clock.current = clock.current.add(const Duration(minutes: 16));
      adapter.offline = true;

      final result = await repository.refreshCurrentUser();

      expect(result.failureOrNull, const Failure.network());
      expect(repository.currentState, isA<Authenticated>());
      expect(await storage.read(), isNotNull);
    });

    test('sessions revoked elsewhere end on the next refresh', () async {
      await signInDemo();
      backend.revokeAllSessions('demo@example.com');

      final result = await repository.refreshCurrentUser();

      expect(result.failureOrNull, const Failure.unauthenticated());
      expect(repository.currentState, isA<Unauthenticated>());
    });
  });

  group('profile', () {
    test('update sends If-Match and refreshes the cached user', () async {
      await signInDemo();

      final result = await repository.updateProfile(displayName: 'Anaz');

      expect(result.valueOrNull?.displayName, 'Anaz');
      expect(adapter.received.last.headers[ApiHeaders.ifMatch], '1');
      expect((await storage.read())?.user.version, 2);
      expect(
        repository.currentState,
        isA<Authenticated>().having((s) => s.user.displayName, 'name', 'Anaz'),
      );
    });
  });

  group('sign-out', () {
    test('revokes server-side, clears storage, signs out of Google', () async {
      await signInDemo();
      final refreshToken = (await storage.read())?.tokens.refreshToken ?? '';

      await repository.signOut();

      expect(
        repository.currentState,
        const AuthState.unauthenticated(reason: SignOutReason.userSignedOut),
      );
      expect(await storage.read(), isNull);
      expect(google.signOutCalls, 1);
      final reuse = await public.dio.post<dynamic>(
        ApiPaths.authRefresh,
        data: {'refresh_token': refreshToken},
        options: Options(validateStatus: (_) => true),
      );
      expect(reuse.statusCode, 401);
    });

    test('works offline: the local session always ends', () async {
      await signInDemo();
      adapter.offline = true;

      final result = await repository.signOut();

      expect(result.isOk, isTrue);
      expect(await storage.read(), isNull);
      expect(repository.currentState, isA<Unauthenticated>());
    });
  });
}
