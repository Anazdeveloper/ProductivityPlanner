import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

/// Asks the server to email a 6-digit code. Succeeds for unknown emails too
/// (the server never reveals whether an account exists).
final class RequestPasswordReset implements UseCase<Unit, String> {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Unit>> call(String email) async {
    final error = CredentialRules.email(email);
    if (error != null) {
      return Err(
        Failure.validation(fieldErrors: {CredentialField.email: error.name}),
      );
    }
    return _repository.requestPasswordReset(
      email: CredentialRules.normalizeEmail(email),
    );
  }
}

final class PasswordResetConfirmation {
  const PasswordResetConfirmation({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  final String email;
  final String code;
  final String newPassword;
}

final class ResetPassword implements UseCase<Unit, PasswordResetConfirmation> {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Unit>> call(PasswordResetConfirmation params) async {
    final errors = CredentialRules.collect({
      CredentialField.email: CredentialRules.email(params.email),
      CredentialField.code: CredentialRules.resetCode(params.code),
      CredentialField.newPassword: CredentialRules.newPassword(
        params.newPassword,
      ),
    });
    if (errors.isNotEmpty) return Err(Failure.validation(fieldErrors: errors));
    return _repository.resetPassword(
      email: CredentialRules.normalizeEmail(params.email),
      code: params.code.trim(),
      newPassword: params.newPassword,
    );
  }
}
