import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

part 'task_draft.freezed.dart';

/// The fields of a series that do not affect which occurrences exist.
/// Editing them never splits the series.
@freezed
abstract class TaskDetails with _$TaskDetails {
  const factory TaskDetails({
    required String title,
    required Duration plannedDuration,
    String? notes,
    String? categoryId,
    @Default(TaskPriority.medium) TaskPriority priority,
    @Default(<Duration>[Duration(minutes: 5)]) List<Duration> reminderOffsets,
  }) = _TaskDetails;
}

/// Input for creating a task (from the form in Phase 5 or voice in Phase 9).
@freezed
abstract class TaskDraft with _$TaskDraft {
  const factory TaskDraft({
    required TaskDetails details,
    required TaskSchedule schedule,
  }) = _TaskDraft;
}
