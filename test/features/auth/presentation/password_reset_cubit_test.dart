import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/auth/domain/usecases/password_reset.dart';
import 'package:productivity_planner/features/auth/domain/usecases/register_with_email.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/password_reset_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/register_cubit.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('PasswordResetCubit', () {
    PasswordResetCubit build({String email = ''}) => PasswordResetCubit(
      requestPasswordReset: RequestPasswordReset(repository),
      resetPassword: ResetPassword(repository),
      initialEmail: email,
    );

    blocTest<PasswordResetCubit, PasswordResetState>(
      'request → confirm → done',
      build: () => build(email: 'demo@example.com'),
      act: (cubit) async {
        await cubit.requestCode();
        cubit
          ..codeChanged('123456')
          ..newPasswordChanged('a-new-password');
        await cubit.confirm();
      },
      verify: (cubit) => expect(cubit.state.step, PasswordResetStep.done),
    );

    blocTest<PasswordResetCubit, PasswordResetState>(
      'the code step starts without errors shown',
      build: () => build(email: 'demo@example.com'),
      act: (cubit) => cubit.requestCode(),
      verify: (cubit) {
        expect(cubit.state.step, PasswordResetStep.confirm);
        expect(cubit.state.codeError, isNull);
      },
    );

    blocTest<PasswordResetCubit, PasswordResetState>(
      'invalid code stays on the confirm step with a field error',
      setUp: () => repository.nextFailure = const Failure.validation(
        fieldErrors: {'code': 'is invalid or expired'},
      ),
      build: () => build(email: 'demo@example.com'),
      seed: () => const PasswordResetState(
        step: PasswordResetStep.confirm,
        email: 'demo@example.com',
        code: '000000',
        newPassword: 'a-new-password',
      ),
      act: (cubit) => cubit.confirm(),
      verify: (cubit) {
        expect(cubit.state.step, PasswordResetStep.confirm);
        expect(cubit.state.serverFieldError('code'), 'is invalid or expired');
        expect(cubit.state.bannerFailure, isNull);
      },
    );

    blocTest<PasswordResetCubit, PasswordResetState>(
      'a malformed code is caught locally',
      build: () => build(email: 'demo@example.com'),
      seed: () => const PasswordResetState(
        step: PasswordResetStep.confirm,
        email: 'demo@example.com',
        code: '12',
        newPassword: 'a-new-password',
      ),
      act: (cubit) => cubit.confirm(),
      verify: (cubit) =>
          expect(cubit.state.codeError, CredentialError.resetCodeInvalid),
    );
  });

  group('RegisterCubit', () {
    blocTest<RegisterCubit, RegisterState>(
      'a short password is caught before calling the repository',
      build: () => RegisterCubit(registerWithEmail: RegisterWithEmail(repository)),
      act: (cubit) async {
        cubit
          ..displayNameChanged('Anaz')
          ..emailChanged('anaz@example.com')
          ..passwordChanged('short');
        await cubit.submit();
      },
      verify: (cubit) {
        expect(cubit.state.passwordError, CredentialError.passwordTooShort);
        expect(repository.signInCalls, 0);
      },
    );

    blocTest<RegisterCubit, RegisterState>(
      'email already taken shows a banner',
      setUp: () =>
          repository.nextFailure = const Failure.conflict(code: 'EMAIL_TAKEN'),
      build: () => RegisterCubit(registerWithEmail: RegisterWithEmail(repository)),
      act: (cubit) async {
        cubit
          ..displayNameChanged('Anaz')
          ..emailChanged('demo@example.com')
          ..passwordChanged('long-enough-pw');
        await cubit.submit();
      },
      verify: (cubit) => expect(
        cubit.state.bannerFailure,
        const Failure.conflict(code: 'EMAIL_TAKEN'),
      ),
    );
  });
}
