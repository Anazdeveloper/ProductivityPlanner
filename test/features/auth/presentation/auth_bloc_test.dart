import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/restore_session.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_out.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  AuthBloc build() => AuthBloc(
    watchAuthState: WatchAuthState(repository),
    restoreSession: RestoreSession(repository),
    signOut: SignOut(repository),
  );

  setUp(() => repository = FakeAuthRepository());

  test('starts in the repository\'s current state', () {
    expect(build().state, const AuthState.unknown());
  });

  blocTest<AuthBloc, AuthState>(
    'restoring a stored session → authenticated',
    setUp: () => repository.restoreTo = const AuthState.authenticated(testUser),
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState.authenticated(testUser)],
  );

  blocTest<AuthBloc, AuthState>(
    'nothing stored → unauthenticated',
    build: build,
    act: (bloc) => bloc.add(const AuthStarted()),
    expect: () => [const AuthState.unauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'follows session changes pushed by the data layer (e.g. expiry)',
    setUp: () => repository = FakeAuthRepository(
      initial: const AuthState.authenticated(testUser),
    ),
    build: build,
    act: (_) => repository.emit(
      const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
    ),
    expect: () => [
      const AuthState.unauthenticated(reason: SignOutReason.sessionExpired),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'sign out → unauthenticated(userSignedOut)',
    setUp: () => repository = FakeAuthRepository(
      initial: const AuthState.authenticated(testUser),
    ),
    build: build,
    act: (bloc) => bloc.add(const AuthSignOutRequested()),
    expect: () => [
      const AuthState.unauthenticated(reason: SignOutReason.userSignedOut),
    ],
    verify: (_) => expect(repository.signOutCalls, 1),
  );
}
