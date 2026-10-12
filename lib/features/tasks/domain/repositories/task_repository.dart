import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';

/// Tasks, their occurrences and work sessions, stored locally first.
///
/// Every write commits the change and its sync op (outbox) in one local
/// transaction, so it succeeds offline. Inputs are validated by the use
/// cases; implementations map storage errors to `Failure.database`.
abstract interface class TaskRepository {
  /// Occurrences scheduled on dates in `[from, to]`, with their series,
  /// category and work sessions. Emits again whenever any of them change.
  Stream<Result<List<AgendaItem>>> watchAgenda({
    required LocalDate from,
    required LocalDate to,
  });

  /// One occurrence; emits null if it does not exist (or was deleted).
  Stream<Result<AgendaItem?>> watchAgendaItem(String occurrenceId);

  /// Every occurrence that has been started and not resolved (any date),
  /// with its work sessions. Usually one: starting a task pauses the
  /// others. Emits again on every change.
  Stream<Result<List<AgendaItem>>> watchInProgress();

  /// Occurrences of every series in one lineage (an activity across
  /// schedule changes) scheduled on dates in `[from, to]`. Emits again on
  /// every change.
  Stream<Result<List<AgendaItem>>> watchLineage(
    String lineageId, {
    required LocalDate from,
    required LocalDate to,
  });

  Future<Result<Task>> getTask(String taskId);

  /// Every series that is not deleted (ended ones included).
  Future<Result<List<Task>>> listTasks();

  /// Saves a new series and its first occurrences.
  Future<Result<Task>> createTask(TaskDraft draft);

  /// Changes fields that do not affect the schedule. A new planned duration
  /// also applies to occurrences from today on that have not started.
  Future<Result<Task>> updateTaskDetails(String taskId, TaskDetails details);

  /// Changes the schedule from [fromDate] on, keeping the history before it.
  ///
  /// A one-off task that stays one-off moves its single occurrence (same
  /// id) to the new slot; it fails with a `start_date` validation error if
  /// that occurrence is already finished. When the task does not repeat,
  /// or [fromDate] is on or before the series' start date, the series is
  /// edited in place; otherwise it is
  /// split: the old series ends the day before and a new one (same
  /// lineage) starts on [fromDate]. Returns the series that carries the new
  /// schedule.
  Future<Result<Task>> rescheduleFrom(
    String taskId, {
    required LocalDate fromDate,
    required TaskSchedule schedule,
  });

  /// Stops the series after [lastDate]. Untouched occurrences after it are
  /// removed; anything the user worked on is kept.
  Future<Result<Unit>> endTask(String taskId, {required LocalDate lastDate});

  /// Deletes the series and all its occurrences.
  Future<Result<Unit>> deleteTask(String taskId);

  /// Runs the lifecycle state machine and persists the outcome.
  Future<Result<LifecycleOutcome>> applyAction(
    String occurrenceId,
    OccurrenceAction action,
  );

  /// Creates missing occurrences for every active series up to the planning
  /// horizon. Idempotent. Returns how many were created.
  Future<Result<int>> materializeOccurrences();
}
