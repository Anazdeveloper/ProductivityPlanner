import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';

abstract interface class SyncRepository {
  /// The current status, then every change.
  Stream<SyncStatus> watchStatus();

  /// Pushes and pulls now. Err carries why it stopped (offline, server).
  Future<Result<Unit>> syncNow();

  /// Refused changes, newest first.
  Stream<Result<List<SyncIssue>>> watchIssues();

  Future<Result<Unit>> dismissIssue(String id);

  Future<Result<Unit>> dismissAllIssues();
}
