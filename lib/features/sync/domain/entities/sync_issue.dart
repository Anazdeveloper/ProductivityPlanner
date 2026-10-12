import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// What a refused change was about.
enum SyncIssueSubject { task, occurrence, category, other }

/// Why the server refused it, in terms the person can act on.
enum SyncIssueReason {
  /// Deleted on another device (or no longer exists).
  deleted,

  /// Changed on another device in a way this change no longer fits.
  conflict,

  /// The plan does not allow it (limit or Pro feature).
  plan,

  /// The server considered it invalid.
  invalid,

  /// Kept failing; given up so later changes can sync.
  failed,
  other;

  /// Contract §2 codes.
  static SyncIssueReason fromCode(String code) => switch (code) {
    'ENTITY_DELETED' || 'NOT_FOUND' => deleted,
    'STALE_VERSION' ||
    'CONFLICT' ||
    'INVALID_TRANSITION' ||
    'ALREADY_RESOLVED' => conflict,
    'LIMIT_REACHED' || 'ENTITLEMENT_REQUIRED' => plan,
    'VALIDATION_FAILED' => invalid,
    'SYNC_FAILED' => failed,
    _ => other,
  };
}

/// A local change the server refused. The local data has already been
/// brought back in line with the server; this tells the person what was
/// lost.
@immutable
final class SyncIssue {
  const SyncIssue({
    required this.id,
    required this.subject,
    required this.reason,
    required this.code,
    required this.createdAt,
    this.label,
  });

  final String id;
  final SyncIssueSubject subject;
  final SyncIssueReason reason;

  /// The server's code, for support.
  final String code;

  /// The task or category name, when it was still known.
  final String? label;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is SyncIssue &&
      other.id == id &&
      other.subject == subject &&
      other.reason == reason &&
      other.code == code &&
      other.label == label &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, subject, reason, code, label, createdAt);
}
