import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity_planner/features/auth/domain/validation/credential_rules.dart';

final class RefreshCurrentUser implements UseCase<User, NoParams> {
  const RefreshCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(NoParams params) =>
      _repository.refreshCurrentUser();
}

final class UpdateDisplayName implements UseCase<User, String> {
  const UpdateDisplayName(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(String displayName) async {
    final error = CredentialRules.displayName(displayName);
    if (error != null) {
      return Err(
        Failure.validation(
          fieldErrors: {CredentialField.displayName: error.name},
        ),
      );
    }
    return _repository.updateProfile(displayName: displayName.trim());
  }
}
