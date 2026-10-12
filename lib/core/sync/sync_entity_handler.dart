import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/sync/sync_models.dart';

/// What a handler did locally about a refused op.
@immutable
final class SyncRejection {
  const SyncRejection({
    this.label,
    this.needsRepair = false,
    this.dropQueued,
  });

  /// A short label for the issue list (a title), if known.
  final String? label;

  /// The local data must still be re-read from the server ([repair]).
  final bool needsRepair;

  /// Queued ops that can only be refused too (they target something that
  /// no longer exists); the engine drops them with this issue.
  final bool Function(SyncOp op)? dropQueued;
}

/// What a feature tells the sync engine about the data it owns. The engine
/// moves ops and changes; handlers know the tables and shapes.
///
/// Rule shared by every method that writes server state: an entity in
/// `pending` (local ops not pushed yet) is never overwritten. The local
/// change wins until the server has it; the merged state then arrives in
/// a later pull.
abstract interface class SyncEntityHandler {
  /// `sync/pull` entity names it applies (e.g. `series`).
  Set<String> get entities;

  /// Pull order within a page: parents before children (lower first).
  int rankOf(String entity);

  /// Whether ops of [opType] (wire string) are about its data.
  bool ownsOp(String opType);

  /// Applies a pulled change, inside the engine's transaction.
  ///
  /// Throws [FormatException] (or another parse error) for a change it
  /// cannot read; the engine reports and skips that change.
  Future<void> applyChange(SyncChange change, {required Set<String> pending});

  /// Records the server version an accepted op produced.
  Future<void> applyVersion(SyncOp op, int version);

  /// The server refused [op]: undo locally what needs no server read
  /// (remove a create the server never accepted, delete what the server
  /// says is deleted). Runs in the push transaction, no network.
  Future<SyncRejection> onRejected(SyncOp op, String code);

  /// Re-reads the entity an op of [opType] targeted and applies the
  /// server's state. True when done (applied, found deleted, or skipped
  /// because it has queued ops); false to retry on a later run (offline,
  /// server error).
  Future<bool> repair(
    String opType,
    String entityId, {
    required Set<String> pending,
  });

  /// After pulled or repaired state was applied (e.g. create missing
  /// occurrences).
  Future<void> afterPull();
}
