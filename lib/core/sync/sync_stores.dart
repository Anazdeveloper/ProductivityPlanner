import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';

/// Reads and settles the outbox for the sync engine (writes come from
/// `OutboxWriter`, inside each change's transaction).
final class OutboxStore {
  const OutboxStore(this._db);

  final AppDatabase _db;

  /// The oldest [limit] ops (all without one), in push order.
  Future<List<SyncOp>> pending({int? limit}) async {
    final query = _db.select(_db.outboxOperations)
      ..orderBy([(t) => OrderingTerm.asc(t.seq)]);
    if (limit != null) query.limit(limit);
    final rows = await query.get();
    return [
      for (final row in rows)
        SyncOp(
          seq: row.seq,
          opId: row.opId,
          type: row.type,
          entityId: row.entityId,
          baseVersion: row.baseVersion,
          occurredAt: row.occurredAt.toUtc(),
          schema: row.payloadSchema,
          payload: Map<String, Object?>.from(
            jsonDecode(row.payload) as Map<String, dynamic>,
          ),
          attempts: row.attempts,
        ),
    ];
  }

  /// Entity ids with ops still waiting: a pull must not overwrite them.
  Future<Set<String>> pendingEntityIds() async {
    final rows = await (_db.selectOnly(
      _db.outboxOperations,
    )..addColumns([_db.outboxOperations.entityId])).get();
    return {
      for (final row in rows)
        if (row.read(_db.outboxOperations.entityId) case final id?) id,
    };
  }

  Future<void> remove(Iterable<String> opIds) {
    final ids = opIds.toList();
    if (ids.isEmpty) return Future.value();
    return (_db.delete(
      _db.outboxOperations,
    )..where((t) => t.opId.isIn(ids))).go();
  }

  /// Counts a failed attempt for [opIds] and remembers why.
  Future<void> recordFailure(Iterable<String> opIds, String error) async {
    final ids = opIds.toList();
    if (ids.isEmpty) return;
    await _db.customUpdate(
      'UPDATE outbox_operations SET attempts = attempts + 1, last_error = ? '
      'WHERE op_id IN (${List.filled(ids.length, '?').join(', ')})',
      variables: [
        Variable.withString(error),
        for (final id in ids) Variable.withString(id),
      ],
      updates: {_db.outboxOperations},
    );
  }
}

/// The `sync/pull` cursor, in `app_meta` (cleared with the user's data).
final class SyncCursorStore {
  const SyncCursorStore(this._meta);

  final AppMetaStore _meta;

  Future<int> read() async =>
      int.tryParse(await _meta.read(AppMetaKeys.syncCursor) ?? '') ?? 0;

  Future<void> write(int cursor) =>
      _meta.write(AppMetaKeys.syncCursor, cursor.toString());
}

/// A change the server refused.
@immutable
final class SyncIssueRecord {
  const SyncIssueRecord({
    required this.id,
    required this.opType,
    required this.entityId,
    required this.code,
    required this.createdAt,
    this.label,
    this.repairPending = false,
  });

  final String id;
  final String opType;
  final String entityId;
  final String code;
  final String? label;
  final bool repairPending;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) => other is SyncIssueRecord && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

final class SyncIssueStore {
  const SyncIssueStore(this._db);

  final AppDatabase _db;

  Future<void> add(SyncIssueRecord issue) => _db
      .into(_db.syncIssues)
      .insertOnConflictUpdate(
        SyncIssuesCompanion.insert(
          id: issue.id,
          opType: issue.opType,
          entityId: issue.entityId,
          code: issue.code,
          label: Value(issue.label),
          repairPending: Value(issue.repairPending),
          createdAt: issue.createdAt.toUtc(),
        ),
      );

  /// Visible issues, newest first.
  Stream<List<SyncIssueRecord>> watch() =>
      (_db.select(_db.syncIssues)
            ..where((t) => t.dismissed.not())
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(_record).toList());

  /// Issues whose local data still has to be re-read, oldest first.
  Future<List<SyncIssueRecord>> pendingRepairs() async {
    final rows =
        await (_db.select(_db.syncIssues)
              ..where((t) => t.repairPending)
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    return rows.map(_record).toList();
  }

  /// The repair is done; a dismissed issue goes away with it.
  Future<void> repaired(String id) => _db.transaction(() async {
    await (_db.delete(
      _db.syncIssues,
    )..where((t) => t.id.equals(id) & t.dismissed)).go();
    await (_db.update(_db.syncIssues)..where((t) => t.id.equals(id))).write(
      const SyncIssuesCompanion(repairPending: Value(false)),
    );
  });

  /// Hides an issue. One with a repair still to do is kept (hidden) until
  /// the repair is done.
  Future<void> dismiss(String id) => _dismissWhere((t) => t.id.equals(id));

  Future<void> dismissAll() => _dismissWhere((_) => const Constant(true));

  Future<void> _dismissWhere(
    Expression<bool> Function($SyncIssuesTable t) filter,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.syncIssues,
    )..where((t) => filter(t) & t.repairPending.not())).go();
    await (_db.update(_db.syncIssues)..where(filter)).write(
      const SyncIssuesCompanion(dismissed: Value(true)),
    );
  });

  static SyncIssueRecord _record(SyncIssueRow row) => SyncIssueRecord(
    id: row.id,
    opType: row.opType,
    entityId: row.entityId,
    code: row.code,
    label: row.label,
    repairPending: row.repairPending,
    createdAt: row.createdAt.toUtc(),
  );
}
