import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/restore_session.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_out.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';

sealed class AuthEvent {
  const AuthEvent();
}

/// Dispatched once at app start.
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class _AuthStateChanged extends AuthEvent {
  const _AuthStateChanged(this.state);

  final AuthState state;
}

/// App-wide session state. A Bloc (not a Cubit) because it merges two
/// sources of events: user intents and session changes pushed by the data
/// layer (sign-in on the sign-in screen, expiry detected by the HTTP layer).
///
/// Its state is the domain [AuthState]; routing reads it through
/// `AuthBlocAuthGate`.
final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required WatchAuthState watchAuthState,
    required RestoreSession restoreSession,
    required SignOut signOut,
  }) : _restoreSession = restoreSession,
       _signOut = signOut,
       super(watchAuthState.current) {
    on<AuthStarted>(_onStarted);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<_AuthStateChanged>((event, emit) => emit(event.state));
    _subscription = watchAuthState().listen(
      (state) => add(_AuthStateChanged(state)),
    );
  }

  final RestoreSession _restoreSession;
  final SignOut _signOut;
  late final StreamSubscription<AuthState> _subscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final result = await _restoreSession(const NoParams());
    // Success is delivered through the session stream; only an unexpected
    // failure needs handling here, and the safe fallback is signed out.
    if (result.isErr) emit(const AuthState.unauthenticated());
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _signOut(const NoParams());
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
