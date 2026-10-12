import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

part 'work_session.freezed.dart';

/// A span of time actually spent on an occurrence.
@freezed
abstract class WorkSession with _$WorkSession {
  const factory WorkSession({
    required String id,
    required String occurrenceId,
    required DateTime startedAt,

    /// Null while running.
    DateTime? endedAt,
    SessionEndReason? endReason,
  }) = _WorkSession;

  const WorkSession._();

  bool get isOpen => endedAt == null;

  /// Length so far; an open session counts up to [now]. Never negative
  /// (device clock corrections can put `now` before `startedAt`).
  Duration elapsed(DateTime now) {
    final end = endedAt ?? now;
    final length = end.difference(startedAt);
    return length.isNegative ? Duration.zero : length;
  }
}

/// Total time across [sessions], counting open ones up to [now].
Duration totalTracked(Iterable<WorkSession> sessions, DateTime now) =>
    sessions.fold(Duration.zero, (sum, s) => sum + s.elapsed(now));
