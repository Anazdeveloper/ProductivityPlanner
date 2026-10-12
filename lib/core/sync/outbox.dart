import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/time/clock.dart';

/// Operation types accepted by `POST sync/push` (contract §4). Wire strings
/// are fixed by the contract.
enum SyncOpType {
  seriesCreate('series.create'),
  seriesUpdate('series.update'),
  seriesDelete('series.delete'),
  seriesSplit('series.split'),
  occurrenceStart('occurrence.start'),
  occurrencePause('occurrence.pause'),
  occurrenceResume('occurrence.resume'),
  occurrenceComplete('occurrence.complete'),
  occurrenceSkip('occurrence.skip'),
  occurrencePostpone('occurrence.postpone'),
  occurrenceCancel('occurrence.cancel'),
  occurrenceReopen('occurrence.reopen'),
  occurrenceUpdate('occurrence.update'),
  categoryCreate('category.create'),
  categoryUpdate('category.update'),
  categoryDelete('category.delete');

  const SyncOpType(this.wire);

  final String wire;
}

/// Current payload schema (`schema` field of an op). Bump when a payload
/// shape changes incompatibly; the server accepts the last two.
const int syncPayloadSchema = 1;

/// Records local changes for the sync engine (Phase 11).
///
/// Call [enqueue] inside the same `AppDatabase.transaction` as the change it
/// describes: drift transactions are zone-scoped, so the insert joins the
/// caller's transaction and the change and its op commit (or roll back)
/// together. A change can never be saved without its op, or vice versa.
final class OutboxWriter {
  const OutboxWriter({
    required AppDatabase db,
    required IdGenerator ids,
    required Clock clock,
  }) : _db = db,
       _ids = ids,
       _clock = clock;

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  /// Returns the new op id.
  Future<String> enqueue({
    required SyncOpType type,
    required String entityId,
    required Map<String, Object?> payload,
    int? baseVersion,
    DateTime? occurredAt,
  }) async {
    final opId = _ids.newId();
    await _db
        .into(_db.outboxOperations)
        .insert(
          OutboxOperationsCompanion.insert(
            opId: opId,
            type: type.wire,
            entityId: entityId,
            baseVersion: Value(baseVersion),
            occurredAt: (occurredAt ?? _clock.now()).toUtc(),
            payloadSchema: const Value(syncPayloadSchema),
            payload: jsonEncode(payload),
          ),
        );
    return opId;
  }

  /// Number of ops not yet acknowledged by the server ("n changes not
  /// synced" in Settings).
  Stream<int> watchPendingCount() {
    final count = _db.outboxOperations.seq.count();
    final query = _db.selectOnly(_db.outboxOperations)..addColumns([count]);
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }
}
