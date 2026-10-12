import 'dart:async';

import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/remote_call.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/auth/data/datasources/account_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/nonce_generator.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/social_credentials.dart';
import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';
import 'package:productivity_planner/features/auth/data/models/user_mapper.dart';
import 'package:productivity_planner/features/auth/data/repositories/auth_session_manager.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/social_sign_in_options.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthSessionManager session,
    required AuthRemoteDataSource authRemote,
    required AccountRemoteDataSource accountRemote,
    required AppleCredentialSource apple,
    required GoogleCredentialSource google,
    required NonceGenerator nonces,
    required DeviceContext device,
    required ErrorReporter reporter,
  }) : _session = session,
       _authRemote = authRemote,
       _accountRemote = accountRemote,
       _apple = apple,
       _google = google,
       _nonces = nonces,
       _device = device,
       _reporter = reporter;

  /// Sign-out waits at most this long for the server before ending locally.
  static const _logoutTimeout = Duration(seconds: 5);

  final AuthSessionManager _session;
  final AuthRemoteDataSource _authRemote;
  final AccountRemoteDataSource _accountRemote;
  final AppleCredentialSource _apple;
  final GoogleCredentialSource _google;
  final NonceGenerator _nonces;
  final DeviceContext _device;
  final ErrorReporter _reporter;

  @override
  AuthState get currentState => _session.state;

  @override
  Stream<AuthState> watchAuthState() => _session.watch();

  @override
  Future<Result<AuthState>> restoreSession() async {
    final state = await _session.restore();
    if (state is Authenticated) {
      // Best effort: picks up profile changes made on another device. An
      // expired session is detected here by the HTTP layer and ends cleanly.
      unawaited(refreshCurrentUser());
    }
    return Ok(state);
  }

  @override
  Future<Result<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _guard(
      () => _authRemote.login(LoginRequestDto(email: email, password: password)),
    );
    // On login, 401 means wrong email or password, not an expired session.
    if (result case Err(failure: UnauthenticatedFailure())) {
      return const Err(Failure.invalidCredentials());
    }
    return _startSession(result);
  }

  @override
  Future<Result<User>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final timeZone = await _device.timeZone();
    return _startSession(
      await _guard(
        () => _authRemote.register(
          RegisterRequestDto(
            email: email,
            password: password,
            displayName: displayName,
            timeZone: timeZone,
            locale: _device.localeTag(),
          ),
        ),
      ),
    );
  }

  @override
  Future<Result<User>> signInWithApple() async {
    final rawNonce = _nonces.generate();
    final AppleCredential credential;
    try {
      credential = await _apple.getCredential(
        hashedNonce: _nonces.sha256Hex(rawNonce),
      );
    } on Object catch (error, stackTrace) {
      return Err(await _providerFailure(error, stackTrace, 'apple'));
    }
    final timeZone = await _device.timeZone();
    return _startSession(
      await _guard(
        () => _authRemote.signInWithApple(
          AppleSignInRequestDto(
            idToken: credential.identityToken,
            rawNonce: rawNonce,
            authorizationCode: credential.authorizationCode,
            displayName: credential.fullName,
            timeZone: timeZone,
            locale: _device.localeTag(),
          ),
        ),
      ),
    );
  }

  @override
  Future<Result<User>> signInWithGoogle() async {
    final GoogleCredential credential;
    try {
      credential = await _google.getCredential();
    } on Object catch (error, stackTrace) {
      return Err(await _providerFailure(error, stackTrace, 'google'));
    }
    final timeZone = await _device.timeZone();
    return _startSession(
      await _guard(
        () => _authRemote.signInWithGoogle(
          GoogleSignInRequestDto(
            idToken: credential.idToken,
            timeZone: timeZone,
            locale: _device.localeTag(),
          ),
        ),
      ),
    );
  }

  @override
  Future<SocialSignInOptions> socialSignInOptions() async {
    final [apple, google] = await Future.wait([
      _apple.isAvailable(),
      _google.isAvailable(),
    ]);
    return SocialSignInOptions(apple: apple, google: google);
  }

  @override
  Future<Result<Unit>> requestPasswordReset({required String email}) async =>
      (await _guard(() => _authRemote.requestPasswordReset(email))).map(
        (_) => unit,
      );

  @override
  Future<Result<Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async => (await _guard(
    () => _authRemote.resetPassword(
      PasswordResetRequestDto(email: email, code: code, newPassword: newPassword),
    ),
  )).map((_) => unit);

  @override
  Future<Result<Unit>> signOut() async {
    final refreshToken = _session.session?.tokens.refreshToken;
    if (refreshToken != null) {
      // Revoke server-side if reachable; never block sign-out on it.
      await _guard(() => _authRemote.logout(refreshToken)).timeout(
        _logoutTimeout,
        onTimeout: () => const Err(Failure.network()),
      );
    }
    await _google.signOut();
    await _session.end(SignOutReason.userSignedOut);
    return const Ok(unit);
  }

  @override
  Future<Result<User>> refreshCurrentUser() async {
    if (_session.session == null) return const Err(Failure.unauthenticated());
    final result = await _guard(_accountRemote.getMe);
    return _applyUser(result);
  }

  @override
  Future<Result<User>> updateProfile({required String displayName}) async {
    final current = _session.session;
    if (current == null) return const Err(Failure.unauthenticated());
    final result = await _guard(
      () => _accountRemote.updateMe(
        UpdateProfileRequestDto(displayName: displayName),
        version: current.user.version,
      ),
    );
    return _applyUser(result);
  }

  Future<Result<User>> _applyUser(Result<UserDto> result) async {
    switch (result) {
      case Ok(:final value):
        await _session.updateUser(value);
        return Ok(value.toDomain());
      case Err(:final failure):
        return Err(failure);
    }
  }

  Future<Result<User>> _startSession(Result<AuthResultDto> result) async {
    switch (result) {
      case Ok(:final value):
        await _session.start(value);
        return Ok(value.user.toDomain());
      case Err(:final failure):
        return Err(failure);
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() call) =>
      guardRemoteCall(call, reporter: _reporter);

  Future<Failure> _providerFailure(
    Object error,
    StackTrace stackTrace,
    String provider,
  ) async {
    if (error is SocialSignInCancelled) return const Failure.cancelled();
    await _reporter.report(error, stackTrace, context: {'provider': provider});
    return Failure.unexpected(cause: error, stackTrace: stackTrace);
  }
}
