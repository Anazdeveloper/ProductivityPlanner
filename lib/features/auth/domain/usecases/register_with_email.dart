import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

final class Registration {
  const Registration({
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String displayName;
  final String email;
  final String password;
}

final class RegisterWithEmail implements UseCase<User, Registration> {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(Registration params) async {
    final errors = CredentialRules.collect({
      CredentialField.displayName: CredentialRules.displayName(
        params.displayName,
      ),
      CredentialField.email: CredentialRules.email(params.email),
      CredentialField.password: CredentialRules.newPassword(params.password),
    });
    if (errors.isNotEmpty) return Err(Failure.validation(fieldErrors: errors));
    return _repository.registerWithEmail(
      email: CredentialRules.normalizeEmail(params.email),
      password: params.password,
      displayName: params.displayName.trim(),
    );
  }
}
