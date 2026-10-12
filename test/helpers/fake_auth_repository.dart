import 'dart:async';

import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/social_sign_in_options.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';

const testUser = User(
  id: 'user-1',
  email: 'demo@example.com',
  displayName: 'Demo User',
  timeZone: 'Asia/Kolkata',
  locale: 'en-IN',
);

/// Scriptable [AuthRepository] for bloc and widget tests. Successful
/// sign-in/registration emits [Authenticated], like the real session.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    AuthState initial = const AuthState.unknown(),
    this.restoreTo = const AuthState.unauthenticated(),
    this.socialOptions = SocialSignInOptions.none,
  }) : _state = initial;

  final _controller = StreamController<AuthState>.broadcast(sync: true);
  AuthState _state;

  AuthState restoreTo;
  SocialSignInOptions socialOptions;

  /// Next result for sign-in / register calls; `null` means success.
  Failure? nextFailure;

  int signInCalls = 0;
  int signOutCalls = 0;
  String? lastPasswordResetEmail;

  void emit(AuthState state) {
    _state = state;
    _controller.add(state);
  }

  Future<Result<User>> _signIn() async {
    signInCalls++;
    final failure = nextFailure;
    if (failure != null) return Err(failure);
    emit(const AuthState.authenticated(testUser));
    return const Ok(testUser);
  }

  @override
  AuthState get currentState => _state;

  @override
  Stream<AuthState> watchAuthState() => Stream<AuthState>.multi((c) {
    c.add(_state);
    final sub = _controller.stream.listen(c.add);
    c.onCancel = sub.cancel;
  });

  @override
  Future<Result<AuthState>> restoreSession() async {
    emit(restoreTo);
    return Ok(restoreTo);
  }

  @override
  Future<Result<User>> signInWithEmail({
    required String email,
    required String password,
  }) => _signIn();

  @override
  Future<Result<User>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) => _signIn();

  @override
  Future<Result<User>> signInWithApple() => _signIn();

  @override
  Future<Result<User>> signInWithGoogle() => _signIn();

  @override
  Future<SocialSignInOptions> socialSignInOptions() async => socialOptions;

  @override
  Future<Result<Unit>> requestPasswordReset({required String email}) async {
    lastPasswordResetEmail = email;
    final failure = nextFailure;
    return failure == null ? const Ok(unit) : Err(failure);
  }

  @override
  Future<Result<Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final failure = nextFailure;
    return failure == null ? const Ok(unit) : Err(failure);
  }

  @override
  Future<Result<Unit>> signOut() async {
    signOutCalls++;
    emit(const AuthState.unauthenticated(reason: SignOutReason.userSignedOut));
    return const Ok(unit);
  }

  @override
  Future<Result<User>> refreshCurrentUser() async => const Ok(testUser);

  @override
  Future<Result<User>> updateProfile({required String displayName}) async {
    final failure = nextFailure;
    if (failure != null) return Err(failure);
    final updated = testUser.copyWith(displayName: displayName);
    emit(AuthState.authenticated(updated));
    return Ok(updated);
  }
}
