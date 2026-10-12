import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/social_sign_in_options.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';

/// The session and the signed-in account. Inputs are already validated by
/// the use cases; implementations map transport errors to `Failure`.
abstract interface class AuthRepository {
  AuthState get currentState;

  /// Emits the current state immediately, then every change (sign-in,
  /// sign-out, session expiry detected by the HTTP layer, profile updates).
  Stream<AuthState> watchAuthState();

  /// Reads the stored session. Works offline: a stored session counts as
  /// signed in until the server says otherwise.
  Future<Result<AuthState>> restoreSession();

  Future<Result<User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<User>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<User>> signInWithApple();

  Future<Result<User>> signInWithGoogle();

  Future<SocialSignInOptions> socialSignInOptions();

  Future<Result<Unit>> requestPasswordReset({required String email});

  Future<Result<Unit>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Always ends the local session, even when the server is unreachable.
  Future<Result<Unit>> signOut();

  /// Fetches the latest profile from the server and updates the session.
  Future<Result<User>> refreshCurrentUser();

  Future<Result<User>> updateProfile({required String displayName});
}
