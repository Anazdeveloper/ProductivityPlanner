import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/sync/domain/repositories/sync_repository.dart';

final class WatchSyncStatus {
  const WatchSyncStatus(this._repository);

  final SyncRepository _repository;

  Stream<SyncStatus> call() => _repository.watchStatus();
}

final class SyncNow implements UseCase<Unit, NoParams> {
  const SyncNow(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<Unit>> call(NoParams params) => _repository.syncNow();
}

final class WatchSyncIssues
    implements StreamUseCase<List<SyncIssue>, NoParams> {
  const WatchSyncIssues(this._repository);

  final SyncRepository _repository;

  @override
  Stream<Result<List<SyncIssue>>> call(NoParams params) =>
      _repository.watchIssues();
}

final class DismissSyncIssue implements UseCase<Unit, String> {
  const DismissSyncIssue(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<Unit>> call(String id) => _repository.dismissIssue(id);
}

final class DismissAllSyncIssues implements UseCase<Unit, NoParams> {
  const DismissAllSyncIssues(this._repository);

  final SyncRepository _repository;

  @override
  Future<Result<Unit>> call(NoParams params) =>
      _repository.dismissAllIssues();
}
