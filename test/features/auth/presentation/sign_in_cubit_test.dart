import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/social_sign_in_options.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:productivity_planner/features/auth/domain/usecases/social_sign_in.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/sign_in_cubit.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  SignInCubit build() => SignInCubit(
    signInWithEmail: SignInWithEmail(repository),
    signInWithApple: SignInWithApple(repository),
    signInWithGoogle: SignInWithGoogle(repository),
    getSocialSignInOptions: GetSocialSignInOptions(repository),
    watchAuthState: WatchAuthState(repository),
  );

  setUp(() => repository = FakeAuthRepository(
    initial: const AuthState.unauthenticated(),
  ));

  test('shows the session-expired notice when the server ended the session', () {
    repository = FakeAuthRepository(
      initial: const AuthState.unauthenticated(
        reason: SignOutReason.sessionExpired,
      ),
    );
    expect(build().state.sessionExpired, isTrue);
  });

  blocTest<SignInCubit, SignInState>(
    'loads available social providers',
    setUp: () => repository.socialOptions =
        const SocialSignInOptions(apple: true, google: false),
    build: build,
    act: (cubit) => cubit.loadOptions(),
    expect: () => [const SignInState(appleAvailable: true)],
  );

  blocTest<SignInCubit, SignInState>(
    'submitting empty fields shows errors and does not call the repository',
    build: build,
    act: (cubit) => cubit.submitEmail(),
    verify: (cubit) {
      expect(cubit.state.emailError, CredentialError.emailEmpty);
      expect(cubit.state.passwordError, CredentialError.passwordEmpty);
      expect(repository.signInCalls, 0);
    },
  );

  blocTest<SignInCubit, SignInState>(
    'valid credentials: busy, then idle without failure',
    build: build,
    act: (cubit) async {
      cubit
        ..emailChanged('demo@example.com')
        ..passwordChanged('password123');
      await cubit.submitEmail();
    },
    skip: 2,
    expect: () => [
      const SignInState(
        email: 'demo@example.com',
        password: 'password123',
        showValidation: true,
      ),
      const SignInState(
        email: 'demo@example.com',
        password: 'password123',
        showValidation: true,
        inProgress: SignInMethod.email,
      ),
      const SignInState(
        email: 'demo@example.com',
        password: 'password123',
        showValidation: true,
      ),
    ],
    verify: (_) => expect(repository.signInCalls, 1),
  );

  blocTest<SignInCubit, SignInState>(
    'wrong password surfaces a banner failure',
    setUp: () => repository.nextFailure = const Failure.invalidCredentials(),
    build: build,
    act: (cubit) async {
      cubit
        ..emailChanged('demo@example.com')
        ..passwordChanged('nope');
      await cubit.submitEmail();
    },
    verify: (cubit) =>
        expect(cubit.state.bannerFailure, const Failure.invalidCredentials()),
  );

  blocTest<SignInCubit, SignInState>(
    'a cancelled provider sheet shows nothing',
    setUp: () => repository.nextFailure = const Failure.cancelled(),
    build: build,
    act: (cubit) => cubit.signInWithGoogle(),
    verify: (cubit) {
      expect(cubit.state.bannerFailure, isNull);
      expect(cubit.state.isBusy, isFalse);
    },
  );
}
