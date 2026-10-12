import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';

/// Observes the session. Not a `StreamUseCase` because it cannot fail:
/// failures surface as state changes (e.g. unauthenticated).
final class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  AuthState get current => _repository.currentState;

  Stream<AuthState> call() => _repository.watchAuthState();
}
