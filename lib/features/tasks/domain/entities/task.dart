import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

part 'task.freezed.dart';

/// A task series: the user's intent ("Run, 30 min, Mon/Wed/Fri 07:00").
/// What happens on a given day lives in its `TaskOccurrence`s.
@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,

    /// Same across "change from this date" splits.
    required String lineageId,
    required String title,
    required Duration plannedDuration,
    required TaskSchedule schedule,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? notes,
    String? categoryId,
    @Default(TaskPriority.medium) TaskPriority priority,

    /// How long before the start to remind. Empty for no reminder; ignored
    /// for any-time tasks.
    @Default(<Duration>[]) List<Duration> reminderOffsets,

    /// Set when the user ended the series: no occurrences after this date.
    LocalDate? endedOn,

    /// Occurrences exist through this date (materialization watermark).
    LocalDate? materializedThrough,

    /// Server row version; 0 until the server has acknowledged the series.
    @Default(0) int version,
  }) = _Task;

  const Task._();

  bool get isRecurring => schedule.rule.isRecurring;

  /// The last date the series can produce, from [endedOn] and the rule's
  /// `until`, whichever is earlier. Null when open-ended.
  LocalDate? get lastPossibleDate {
    final until = schedule.rule.until;
    final ended = endedOn;
    if (until == null) return ended;
    if (ended == null) return until;
    return minDate(until, ended);
  }
}
