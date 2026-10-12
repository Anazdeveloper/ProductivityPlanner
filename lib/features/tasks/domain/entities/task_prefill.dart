import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

part 'task_prefill.freezed.dart';

/// Suggested values for a new task (e.g. understood from a spoken
/// sentence). Nothing is saved from it directly: the editor opens with
/// these values and the person confirms with Save. Null fields keep the
/// editor's defaults.
@freezed
abstract class TaskPrefill with _$TaskPrefill {
  const factory TaskPrefill({
    String? title,
    LocalDate? date,

    /// Null with [anyTime] false: not said, the editor picks its default.
    LocalTime? time,

    /// Explicitly "any time that day".
    @Default(false) bool anyTime,
    Duration? duration,
    RecurrenceRule? recurrence,
    String? categoryId,

    /// What the values were made from (the spoken sentence), shown so the
    /// person can check them.
    String? originText,
  }) = _TaskPrefill;
}
