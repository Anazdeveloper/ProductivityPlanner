import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

part 'task_occurrence.freezed.dart';

/// One dated instance of a series, with its own lifecycle.
///
/// The id is `UUIDv5(seriesId, originalDate)`, so the same occurrence
/// created offline on two devices is one row everywhere.
@freezed
abstract class TaskOccurrence with _$TaskOccurrence {
  const factory TaskOccurrence({
    required String id,
    required String seriesId,

    /// The date the recurrence produced. Never changes.
    required LocalDate originalDate,

    /// The date it is currently planned for; differs after a postpone.
    required LocalDate scheduledDate,

    /// Copied from the series when created, so editing the series later
    /// does not rewrite history.
    required Duration plannedDuration,
    required DateTime createdAt,
    required DateTime updatedAt,

    /// UTC start; null for an any-time task.
    DateTime? scheduledStart,

    /// UTC start the rule produced; kept across postpones.
    DateTime? originalStart,

    @Default(OccurrenceStatus.scheduled) OccurrenceStatus status,
    @Default(0) int postponeCount,

    /// When work first started.
    DateTime? actualStart,

    /// Time actually spent. Null means not measured (completed without a
    /// timer and without an entered duration), which is not the same as 0.
    Duration? actualDuration,

    /// When it became completed, skipped or cancelled.
    DateTime? resolvedAt,
    SkipReason? skipReason,
    String? note,

    /// Server row version; 0 until the server knows the occurrence.
    @Default(0) int version,
  }) = _TaskOccurrence;

  const TaskOccurrence._();

  bool get isAnyTime => scheduledStart == null;

  bool get wasPostponed => postponeCount > 0;

  /// Untouched by the user: safe to delete or rewrite when the series'
  /// schedule changes.
  bool get isPristine =>
      status == OccurrenceStatus.scheduled &&
      postponeCount == 0 &&
      actualStart == null &&
      (note?.isEmpty ?? true);
}
