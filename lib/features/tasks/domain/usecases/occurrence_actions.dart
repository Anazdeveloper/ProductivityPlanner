import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';

final class OccurrenceActionParams {
  const OccurrenceActionParams({
    required this.occurrenceId,
    required this.action,
  });

  final String occurrenceId;
  final OccurrenceAction action;
}

/// Start, pause, complete, skip, postpone, cancel, reopen or annotate an
/// occurrence. Rules live in `OccurrenceLifecycle`; this persists them.
final class ApplyOccurrenceAction
    implements UseCase<LifecycleOutcome, OccurrenceActionParams> {
  const ApplyOccurrenceAction(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<LifecycleOutcome>> call(OccurrenceActionParams params) =>
      _repository.applyAction(params.occurrenceId, params.action);
}

/// Tops occurrences up to the planning horizon. Run on sign-in, on app
/// resume (Phase 5) and after sync (Phase 11).
final class EnsureOccurrencesMaterialized implements UseCase<int, NoParams> {
  const EnsureOccurrencesMaterialized(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<int>> call(NoParams params) =>
      _repository.materializeOccurrences();
}
