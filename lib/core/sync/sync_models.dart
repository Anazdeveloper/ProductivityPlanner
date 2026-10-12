import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// An outbox row on its way to `POST sync/push` (contract §4).
@immutable
final class SyncOp {
  const SyncOp({
    required this.seq,
    required this.opId,
    required this.type,
    required this.entityId,
    required this.occurredAt,
    required this.schema,
    required this.payload,
    this.baseVersion,
    this.attempts = 0,
  });

  /// Local push order.
  final int seq;
  final String opId;

  /// Wire type, e.g. `occurrence.complete`.
  final String type;
  final String entityId;
  final int? baseVersion;
  final DateTime occurredAt;
  final int schema;
  final Map<String, Object?> payload;
  final int attempts;

  Map<String, Object?> toJson() => {
    'op_id': opId,
    'type': type,
    'entity_id': entityId,
    'base_version': baseVersion,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'schema': schema,
    'payload': payload,
  };

  @override
  bool operator ==(Object other) => other is SyncOp && other.opId == opId;

  @override
  int get hashCode => opId.hashCode;
}

enum PushStatus {
  /// Applied now.
  applied,

  /// Already applied earlier (a retry): nothing to do.
  duplicate,

  /// Applied after merging with a concurrent change; the merged state
  /// arrives with the next pull.
  merged,

  /// Refused; [PushResult.code] says why.
  rejected,
}

@immutable
final class PushResult {
  const PushResult({
    required this.opId,
    required this.status,
    this.version,
    this.code,
  });

  final String opId;
  final PushStatus status;

  /// The entity's server version after the op.
  final int? version;

  /// The problem `code` of a rejected op.
  final String? code;

  @override
  bool operator ==(Object other) =>
      other is PushResult &&
      other.opId == opId &&
      other.status == status &&
      other.version == version &&
      other.code == code;

  @override
  int get hashCode => Object.hash(opId, status, version, code);
}

/// One row of `GET sync/pull` (contract §4.3).
@immutable
final class SyncChange {
  const SyncChange({
    required this.entity,
    required this.id,
    required this.version,
    required this.deleted,
    required this.data,
  });

  /// `series`, `occurrence`, `work_session`, `category`, …
  final String entity;
  final String id;
  final int version;
  final bool deleted;

  /// The entity's full state (empty when [deleted]).
  final Map<String, Object?> data;

  @override
  bool operator ==(Object other) =>
      other is SyncChange &&
      other.entity == entity &&
      other.id == id &&
      other.version == version &&
      other.deleted == deleted;

  @override
  int get hashCode => Object.hash(entity, id, version, deleted);
}

@immutable
final class PullPage {
  const PullPage({
    required this.changes,
    required this.cursor,
    required this.hasMore,
  });

  final List<SyncChange> changes;
  final int cursor;
  final bool hasMore;
}
