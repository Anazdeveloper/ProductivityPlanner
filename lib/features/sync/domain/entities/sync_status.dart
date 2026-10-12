import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/error/failure.dart';

/// Where the local data stands against the server.
@immutable
final class SyncStatus {
  const SyncStatus({
    this.pendingChanges = 0,
    this.syncing = false,
    this.online = true,
    this.lastSyncedAt,
    this.lastFailure,
  });

  /// Local changes the server has not acknowledged yet.
  final int pendingChanges;
  final bool syncing;

  /// The device has a network (a hint: being online can still fail).
  final bool online;

  /// The last run that pushed and pulled everything (this app session).
  final DateTime? lastSyncedAt;

  /// Why the last run stopped; null after a successful one.
  final Failure? lastFailure;

  bool get upToDate =>
      pendingChanges == 0 && lastFailure == null && lastSyncedAt != null;

  @override
  bool operator ==(Object other) =>
      other is SyncStatus &&
      other.pendingChanges == pendingChanges &&
      other.syncing == syncing &&
      other.online == online &&
      other.lastSyncedAt == lastSyncedAt &&
      other.lastFailure == lastFailure;

  @override
  int get hashCode =>
      Object.hash(pendingChanges, syncing, online, lastSyncedAt, lastFailure);
}
