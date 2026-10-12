import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/reminder_scheduler.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';

/// Buttons on a reminder notification.
enum ReminderAction {
  /// Mark the occurrence done (duration not measured).
  done,

  /// Remind again in [HandleReminderAction.snoozeFor].
  snooze,
}

final class ReminderActionParams {
  const ReminderActionParams({
    required this.occurrenceId,
    required this.action,
  });

  final String occurrenceId;
  final ReminderAction action;
}

/// Handles a notification button, possibly in a background isolate with
/// the app's UI not running. Writes go through the normal task repository
/// (same transaction + outbox), then reminders are reconciled.
final class HandleReminderAction implements UseCase<Unit, ReminderActionParams> {
  const HandleReminderAction({
    required TaskRepository tasks,
    required ReminderScheduler scheduler,
    required ReconcileReminders reconcile,
    required Clock clock,
  }) : _tasks = tasks,
       _scheduler = scheduler,
       _reconcile = reconcile,
       _clock = clock;

  static const snoozeFor = Duration(minutes: 10);

  final TaskRepository _tasks;
  final ReminderScheduler _scheduler;
  final ReconcileReminders _reconcile;
  final Clock _clock;

  @override
  Future<Result<Unit>> call(ReminderActionParams params) async {
    final outcome = switch (params.action) {
      ReminderAction.done => await _done(params.occurrenceId),
      ReminderAction.snooze => await _snooze(params.occurrenceId),
    };
    // Even after a failed action, bring notifications back in line.
    await _reconcile(const NoParams());
    return outcome;
  }

  Future<Result<Unit>> _done(String occurrenceId) async {
    final result = await _tasks.applyAction(
      occurrenceId,
      const CompleteOccurrence(),
    );
    return switch (result) {
      Ok() => const Ok(unit),
      // Already completed elsewhere (another device, the app): nothing to do.
      Err(failure: ConflictFailure()) => const Ok(unit),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<Unit>> _snooze(String occurrenceId) async {
    final found = await _tasks.watchAgendaItem(occurrenceId).first;
    if (found case Err(:final failure)) return Err(failure);
    final item = found.valueOrNull;
    final start = item?.occurrence.scheduledStart;
    if (item == null ||
        start == null ||
        item.occurrence.status != OccurrenceStatus.scheduled) {
      return const Ok(unit);
    }
    try {
      await _scheduler.schedule(
        ReminderRequest(
          id: reminderNotificationId(occurrenceId, ReminderKind.snooze),
          occurrenceId: occurrenceId,
          kind: ReminderKind.snooze,
          fireAt: _clock.now().add(snoozeFor),
          taskTitle: item.task.title,
          startAt: start,
          timeZone: item.task.schedule.timeZone,
        ),
      );
      return const Ok(unit);
    } on Object catch (error, stackTrace) {
      return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
    }
  }
}
