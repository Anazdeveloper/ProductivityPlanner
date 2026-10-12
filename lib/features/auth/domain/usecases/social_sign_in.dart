import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/social_sign_in_options.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';

final class SignInWithApple implements UseCase<User, NoParams> {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(NoParams params) => _repository.signInWithApple();
}

final class SignInWithGoogle implements UseCase<User, NoParams> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User>> call(NoParams params) => _repository.signInWithGoogle();
}

/// Which provider buttons to show. Cannot fail: unavailable means hidden.
final class GetSocialSignInOptions {
  const GetSocialSignInOptions(this._repository);

  final AuthRepository _repository;

  Future<SocialSignInOptions> call() => _repository.socialSignInOptions();
}
