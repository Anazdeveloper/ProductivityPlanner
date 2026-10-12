import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';

part 'auth_state.freezed.dart';

/// Why the user is signed out, so the sign-in screen can explain it.
enum SignOutReason {
  /// First launch, or no stored session.
  none,

  /// The user chose to sign out.
  userSignedOut,

  /// The server ended the session (refresh token expired, revoked or reused).
  sessionExpired,
}

@freezed
sealed class AuthState with _$AuthState {
  /// The stored session has not been read yet (app start).
  const factory AuthState.unknown() = AuthUnknown;

  const factory AuthState.authenticated(User user) = Authenticated;

  const factory AuthState.unauthenticated({
    @Default(SignOutReason.none) SignOutReason reason,
  }) = Unauthenticated;
}
