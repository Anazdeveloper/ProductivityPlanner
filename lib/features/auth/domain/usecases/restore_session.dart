import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';

final class RestoreSession implements UseCase<AuthState, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthState>> call(NoParams params) =>
      _repository.restoreSession();
}
