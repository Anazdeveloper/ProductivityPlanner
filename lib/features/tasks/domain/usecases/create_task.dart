import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/task_plan_policy.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

/// Creates a task and its first occurrences, within what the plan allows
/// ([TaskPlanPolicy]).
final class CreateTask implements UseCase<Task, TaskDraft> {
  const CreateTask({
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
  Future<Result<Task>> call(TaskDraft draft) async {
    final zone = draft.schedule.timeZone;
    // An unknown zone is reported by the rules; "today" then falls back to
    // UTC only so the remaining fields can still be checked.
    final today = _converter.localDate(
      _clock.now(),
      _converter.isValidZone(zone) ? zone : 'UTC',
    );
    final valid = _rules.validateDraft(draft, today: today);
    if (valid case Err(:final failure)) return Err(failure);
    final tasks = await _repository.listTasks();
    if (tasks case Err(:final failure)) return Err(failure);
    final denied = _policy.check(
      draft.schedule,
      tasks: tasks.valueOrNull ?? const [],
      today: today,
    );
    if (denied != null) return Err(denied);
    return await _repository.createTask(_normalize(draft));
  }

  TaskDraft _normalize(TaskDraft draft) {
    final details = draft.details;
    final notes = details.notes?.trim();
    final rule = draft.schedule.rule;
    return draft.copyWith(
      details: details.copyWith(
        title: details.title.trim(),
        notes: notes == null || notes.isEmpty ? null : notes,
        reminderOffsets: [...details.reminderOffsets]..sort(),
      ),
      schedule: draft.schedule.copyWith(
        rule: rule.copyWith(weekdays: [...rule.weekdays.toSet()]..sort()),
      ),
    );
  }
}
