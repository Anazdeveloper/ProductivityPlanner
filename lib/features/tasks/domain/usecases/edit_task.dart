import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/task_plan_policy.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

final class UpdateTaskDetailsParams {
  const UpdateTaskDetailsParams({required this.taskId, required this.details});

  final String taskId;
  final TaskDetails details;
}

/// Edits title, notes, category, priority, duration and reminders.
final class UpdateTaskDetails
    implements UseCase<Task, UpdateTaskDetailsParams> {
  const UpdateTaskDetails({
    required TaskRepository repository,
    required TaskRules rules,
  }) : _repository = repository,
       _rules = rules;

  final TaskRepository _repository;
  final TaskRules _rules;

  @override
  Future<Result<Task>> call(UpdateTaskDetailsParams params) async {
    final valid = _rules.validateDetails(params.details);
    if (valid case Err(:final failure)) return Err(failure);
    final notes = params.details.notes?.trim();
    return await _repository.updateTaskDetails(
      params.taskId,
      params.details.copyWith(
        title: params.details.title.trim(),
        notes: notes == null || notes.isEmpty ? null : notes,
        reminderOffsets: [...params.details.reminderOffsets]..sort(),
      ),
    );
  }
}

final class RescheduleTaskParams {
  const RescheduleTaskParams({
    required this.taskId,
    required this.fromDate,
    required this.schedule,
  });

  final String taskId;

  /// First date the new schedule applies to.
  final LocalDate fromDate;

  /// The new schedule. Its start date is replaced by [fromDate].
  final TaskSchedule schedule;
}

/// "Change this and following": edits the schedule from a date on without
/// rewriting what already happened, within what the plan allows.
final class RescheduleTaskFrom implements UseCase<Task, RescheduleTaskParams> {
  const RescheduleTaskFrom({
    required TaskRepository repository,
    required TaskRules rules,
    required TaskPlanPolicy policy,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _repository = repository,
       _rules = rules,
       _policy = policy,
       _converter = converter,
       _clock = clock;

  final TaskRepository _repository;
  final TaskRules _rules;
  final TaskPlanPolicy _policy;
  final TimeZoneConverter _converter;
  final Clock _clock;

  @override
  Future<Result<Task>> call(RescheduleTaskParams params) async {
    final schedule = params.schedule.copyWith(startDate: params.fromDate);
    final valid = _rules.validateSchedule(schedule);
    if (valid case Err(:final failure)) return Err(failure);

    final today = _converter.localDate(_clock.now(), schedule.timeZone);
    if (params.fromDate < today) {
      return const Err(
        Failure.validation(
          fieldErrors: {TaskFields.startDate: TaskRuleCodes.inPast},
        ),
      );
    }
    final original = await _repository.getTask(params.taskId);
    if (original case Err(:final failure)) return Err(failure);
    final tasks = await _repository.listTasks();
    if (tasks case Err(:final failure)) return Err(failure);
    final denied = _policy.check(
      schedule,
      tasks: tasks.valueOrNull ?? const [],
      today: today,
      editing: original.valueOrNull,
    );
    if (denied != null) return Err(denied);
    final rule = schedule.rule;
    return await _repository.rescheduleFrom(
      params.taskId,
      fromDate: params.fromDate,
      schedule: schedule.copyWith(
        rule: rule.copyWith(weekdays: [...rule.weekdays.toSet()]..sort()),
      ),
    );
  }
}

final class EndTaskParams {
  const EndTaskParams({required this.taskId, this.includeToday = true});

  final String taskId;

  /// Keep today's occurrence (true) or end before today (false).
  final bool includeToday;
}

/// Stops a recurring task from repeating; history stays.
final class EndTask implements UseCase<Unit, EndTaskParams> {
  const EndTask({
    required TaskRepository repository,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _repository = repository,
       _converter = converter,
       _clock = clock;

  final TaskRepository _repository;
  final TimeZoneConverter _converter;
  final Clock _clock;

  @override
  Future<Result<Unit>> call(EndTaskParams params) async {
    final found = await _repository.getTask(params.taskId);
    return await found.andThen((task) {
      final today = _converter.localDate(
        _clock.now(),
        task.schedule.timeZone,
      );
      return _repository.endTask(
        task.id,
        lastDate: params.includeToday ? today : today.addDays(-1),
      );
    });
  }
}

/// Deletes a task and all of its history.
final class DeleteTask implements UseCase<Unit, String> {
  const DeleteTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<Unit>> call(String taskId) => _repository.deleteTask(taskId);
}
