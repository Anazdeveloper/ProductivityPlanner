import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

final class EmailCredentials {
  const EmailCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

final class SignInWithEmail implements UseCase<User, EmailCredentials> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(EmailCredentials params) async {
    final errors = CredentialRules.collect({
      CredentialField.email: CredentialRules.email(params.email),
      CredentialField.password: CredentialRules.existingPassword(
        params.password,
      ),
    });
    if (errors.isNotEmpty) return Err(Failure.validation(fieldErrors: errors));
    return _repository.signInWithEmail(
      email: CredentialRules.normalizeEmail(params.email),
      password: params.password,
    );
  }
}
