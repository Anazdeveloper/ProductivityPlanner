import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/auth/domain/usecases/password_reset.dart';
import 'package:productivity_planner/features/auth/domain/usecases/register_with_email.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  group('CredentialRules', () {
    test('email: trims, lower-cases and checks shape', () {
      expect(CredentialRules.normalizeEmail('  Demo@Example.COM '), 'demo@example.com');
      expect(CredentialRules.email(''), CredentialError.emailEmpty);
      expect(CredentialRules.email('   '), CredentialError.emailEmpty);
      expect(CredentialRules.email('demo@'), CredentialError.emailInvalid);
      expect(CredentialRules.email('demo@example'), CredentialError.emailInvalid);
      expect(CredentialRules.email(' Demo@Example.com '), isNull);
    });

    test('new password: 10 to 128 characters, no composition rules', () {
      expect(CredentialRules.newPassword(''), CredentialError.passwordEmpty);
      expect(CredentialRules.newPassword('a' * 9), CredentialError.passwordTooShort);
      expect(CredentialRules.newPassword('a' * 10), isNull);
      expect(CredentialRules.newPassword('a' * 128), isNull);
      expect(CredentialRules.newPassword('a' * 129), CredentialError.passwordTooLong);
    });

    test('existing password: only emptiness is checked', () {
      expect(CredentialRules.existingPassword(''), CredentialError.passwordEmpty);
      expect(CredentialRules.existingPassword('short'), isNull);
    });

    test('display name and reset code', () {
      expect(CredentialRules.displayName('  '), CredentialError.displayNameEmpty);
      expect(CredentialRules.displayName('a' * 61), CredentialError.displayNameTooLong);
      expect(CredentialRules.displayName(' Anaz '), isNull);
      expect(CredentialRules.resetCode('12345'), CredentialError.resetCodeInvalid);
      expect(CredentialRules.resetCode('12a456'), CredentialError.resetCodeInvalid);
      expect(CredentialRules.resetCode(' 123456 '), isNull);
    });
  });

  group('use cases validate before touching the repository', () {
    test('SignInWithEmail returns field codes and does not call the repo', () async {
      final repo = FakeAuthRepository();
      final result = await SignInWithEmail(repo)(
        const EmailCredentials(email: 'bad', password: ''),
      );
      expect(
        result.failureOrNull,
        const Failure.validation(
          fieldErrors: {'email': 'emailInvalid', 'password': 'passwordEmpty'},
        ),
      );
      expect(repo.signInCalls, 0);
    });

    test('RegisterWithEmail enforces new-password rules', () async {
      final repo = FakeAuthRepository();
      final result = await RegisterWithEmail(repo)(
        const Registration(displayName: 'A', email: 'a@b.co', password: 'short'),
      );
      expect(
        result.failureOrNull,
        const Failure.validation(fieldErrors: {'password': 'passwordTooShort'}),
      );
      expect(repo.signInCalls, 0);
    });

    test('RequestPasswordReset normalises the email it sends', () async {
      final repo = FakeAuthRepository();
      final result = await RequestPasswordReset(repo)('  Demo@Example.com ');
      expect(result.isOk, isTrue);
      expect(repo.lastPasswordResetEmail, 'demo@example.com');
    });
  });
}
