import 'dart:async';

import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';
import 'package:productivity_planner/core/network/remote_call.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/session_storage.dart';
import 'package:productivity_planner/features/auth/data/models/auth_dtos.dart';
import 'package:productivity_planner/features/auth/data/models/user_mapper.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';

/// The single owner of the session: in-memory copy, persistence, the
/// [AuthState] stream, and token refresh for the HTTP layer.
///
/// Keeping all of this in one object means the HTTP layer detecting an
/// expired session and the UI signing out go through the same path, so the
/// app can never think it is signed in with no tokens (or the reverse).
final class AuthSessionManager implements AuthTokenProvider {
  AuthSessionManager({
    required SessionStorage storage,
    required AuthRemoteDataSource remote,
    required Clock clock,
    required AppLogger logger,
    required ErrorReporter reporter,
  }) : _storage = storage,
       _remote = remote,
       _clock = clock,
       _logger = logger,
       _reporter = reporter;

  final SessionStorage _storage;
  final AuthRemoteDataSource _remote;
  final Clock _clock;
  final AppLogger _logger;
  final ErrorReporter _reporter;

  final _changes = StreamController<AuthState>.broadcast(sync: true);
  StoredSessionDto? _session;
  AuthState _state = const AuthState.unknown();
  Future<TokenRefreshResult>? _refreshInFlight;

  AuthState get state => _state;

  StoredSessionDto? get session => _session;

  /// Current state first, then every change; no gap between the two.
  Stream<AuthState> watch() => Stream<AuthState>.multi((controller) {
    controller.add(_state);
    final subscription = _changes.stream.listen(
      controller.add,
      onDone: controller.close,
    );
    controller.onCancel = subscription.cancel;
  });

  /// Loads the stored session without touching the network.
  Future<AuthState> restore() async {
    final StoredSessionDto? stored;
    try {
      stored = await _storage.read();
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'op': 'session.read'});
      _emit(const AuthState.unauthenticated());
      return _state;
    }

    if (stored == null) {
      _emit(const AuthState.unauthenticated());
    } else if (!stored.tokens.refreshTokenExpiresAt.isAfter(_clock.now())) {
      await _clearStorage();
      _emit(const AuthState.unauthenticated(reason: SignOutReason.sessionExpired));
    } else {
      _session = stored;
      _emit(AuthState.authenticated(stored.user.toDomain()));
    }
    return _state;
  }

  /// Starts a session after sign-in or registration.
  Future<void> start(AuthResultDto result) async {
    final session = StoredSessionDto(tokens: result.tokens, user: result.user);
    _session = session;
    await _persist(session);
    _emit(AuthState.authenticated(session.user.toDomain()));
  }

  /// Replaces the cached profile (after `GET`/`PATCH me`).
  Future<void> updateUser(UserDto user) async {
    final current = _session;
    if (current == null) return;
    final next = current.copyWith(user: user);
    _session = next;
    await _persist(next);
    _emit(AuthState.authenticated(user.toDomain()));
  }

  /// Ends the session locally. Local user data is wiped by
  /// `UserSessionCoordinator` (config/session) when the reason is an
  /// explicit sign-out; auth does not know about the database.
  Future<void> end(SignOutReason reason) async {
    _session = null;
    await _clearStorage();
    _emit(AuthState.unauthenticated(reason: reason));
  }

  // ---- AuthTokenProvider (used by AuthInterceptor) ----

  @override
  Future<String?> accessToken() async => _session?.tokens.accessToken;

  /// Single flight: concurrent callers share one refresh request, because a
  /// refresh token can be used only once (reuse revokes the whole family).
  @override
  Future<TokenRefreshResult> refresh() =>
      _refreshInFlight ??= _refresh().whenComplete(
        () => _refreshInFlight = null,
      );

  @override
  Future<void> onSessionExpired() async {
    if (_session == null) return;
    _logger.info('session expired');
    await end(SignOutReason.sessionExpired);
  }

  Future<TokenRefreshResult> _refresh() async {
    final current = _session;
    if (current == null) return const TokenRefreshRejected();

    final result = await guardRemoteCall(
      () => _remote.refresh(current.tokens.refreshToken),
      reporter: _reporter,
    );

    final latest = _session;
    if (latest == null) return const TokenRefreshRejected();
    if (latest.tokens.refreshToken != current.tokens.refreshToken) {
      // Signed in again while this refresh was running: the new session wins.
      return TokenRefreshed(latest.tokens.accessToken);
    }

    switch (result) {
      case Ok(:final value):
        final next = latest.copyWith(tokens: value);
        _session = next;
        await _persist(next);
        return TokenRefreshed(value.accessToken);
      case Err(:final failure):
        return switch (failure) {
          // The server looked at the token and refused it.
          UnauthenticatedFailure() ||
          ForbiddenFailure() ||
          ValidationFailure() => const TokenRefreshRejected(),
          // Could not ask (offline, timeout, 5xx): keep the session.
          _ => const TokenRefreshUnavailable(),
        };
    }
  }

  /// Storage failures must not break the in-memory session: the user stays
  /// signed in for this launch and the error is reported.
  Future<void> _persist(StoredSessionDto session) async {
    try {
      await _storage.write(session);
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'op': 'session.write'});
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clear();
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'op': 'session.clear'});
    }
  }

  void _emit(AuthState next) {
    _state = next;
    _changes.add(next);
  }

  Future<void> dispose() => _changes.close();
}
