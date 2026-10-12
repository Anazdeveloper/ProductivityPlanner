import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/notification_settings.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/reminder_scheduler.dart';
import 'package:productivity_planner/features/notifications/domain/services/reminder_planner.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';

/// What a reconciliation did.
final class ReconcileReport {
  const ReconcileReport({
    required this.permission,
    required this.remindersEnabled,
    required this.wanted,
    this.scheduled = 0,
    this.cancelled = 0,
    this.kept = 0,
  });

  final NotificationPermission permission;
  final bool remindersEnabled;

  /// Reminders the tasks call for, whether or not they could be scheduled
  /// (used to decide if asking for permission makes sense).
  final int wanted;
  final int scheduled;
  final int cancelled;
  final int kept;

  bool get active =>
      remindersEnabled && permission == NotificationPermission.granted;
}

/// Makes the device's pending reminders match the tasks.
///
/// Desired state = [ReminderPlanner] over the upcoming agenda, or nothing
/// when reminders are switched off or not permitted. The platform's pending
/// list is diffed against it by id and fingerprint, so an unchanged
/// reminder is left alone and editing, postponing, completing or deleting
/// a task replaces or cancels exactly the affected notifications.
/// Idempotent: run it as often as needed.
///
/// Time-zone changes need no special handling: reminders are absolute
/// instants computed in each task's own zone.
final class ReconcileReminders implements UseCase<ReconcileReport, NoParams> {
  const ReconcileReminders({
    required TaskRepository tasks,
    required ReminderScheduler scheduler,
    required NotificationPermissions permissions,
    required ReminderSettings settings,
    required ReminderPlanner planner,
    required HomeTimeZone homeTimeZone,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _tasks = tasks,
       _scheduler = scheduler,
       _permissions = permissions,
       _settings = settings,
       _planner = planner,
       _homeTimeZone = homeTimeZone,
       _converter = converter,
       _clock = clock;

  final TaskRepository _tasks;
  final ReminderScheduler _scheduler;
  final NotificationPermissions _permissions;
  final ReminderSettings _settings;
  final ReminderPlanner _planner;
  final HomeTimeZone _homeTimeZone;
  final TimeZoneConverter _converter;
  final Clock _clock;

  @override
  Future<Result<ReconcileReport>> call(NoParams params) async {
    try {
      final now = _clock.now();
      final enabled = await _settings.remindersEnabled();
      final permission = await _permissions.status();

      final List<AgendaItem> items;
      if (enabled) {
        final upcoming = await _upcoming(now);
        if (upcoming case Err(:final failure)) return Err(failure);
        items = upcoming.valueOrNull ?? const [];
      } else {
        items = const [];
      }

      final planned = _planner.plan(items, now: now);
      final active = enabled && permission == NotificationPermission.granted;
      final desired = {
        if (active)
          for (final request in planned) request.id: request,
      };
      final byOccurrence = {
        for (final item in items) item.occurrence.id: item,
      };

      var cancelled = 0;
      var kept = 0;
      for (final pending in await _scheduler.pending()) {
        final bool keep;
        switch (pending.kind) {
          case ReminderKind.snooze:
            final item = byOccurrence[pending.occurrenceId];
            keep = active && item != null && _planner.snoozeStillWanted(item);
          case ReminderKind.reminder:
            keep = desired[pending.id]?.fingerprint == pending.fingerprint;
            if (keep) desired.remove(pending.id);
        }
        if (keep) {
          kept++;
        } else {
          await _scheduler.cancel(pending.id);
          cancelled++;
        }
      }
      for (final request in desired.values) {
        await _scheduler.schedule(request);
      }

      return Ok(
        ReconcileReport(
          permission: permission,
          remindersEnabled: enabled,
          wanted: planned.length,
          scheduled: desired.length,
          cancelled: cancelled,
          kept: kept,
        ),
      );
    } on Object catch (error, stackTrace) {
      return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
    }
  }

  /// Occurrences from yesterday (late-evening tasks in zones ahead of the
  /// home zone) to the end of the planning horizon.
  Future<Result<List<AgendaItem>>> _upcoming(DateTime now) async {
    final zone = await _homeTimeZone.current();
    final today = _converter.localDate(
      now,
      _converter.isValidZone(zone) ? zone : 'UTC',
    );
    return await _tasks
        .watchAgenda(
          from: today.addDays(-1),
          to: today.addDays(OccurrencePlanner.horizonDays),
        )
        .first;
  }
}

/// Sign-out: ends the reminder session (so background isolates stop), then
/// removes every notification of the app.
final class CancelAllReminders implements UseCase<Unit, NoParams> {
  const CancelAllReminders({
    required ReminderScheduler scheduler,
    required ReminderSettings settings,
  }) : _scheduler = scheduler,
       _settings = settings;

  final ReminderScheduler _scheduler;
  final ReminderSettings _settings;

  @override
  Future<Result<Unit>> call(NoParams params) async {
    try {
      await _settings.setRemindersSessionActive(active: false);
      await _scheduler.cancelAll();
      return const Ok(unit);
    } on Object catch (error, stackTrace) {
      return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
    }
  }
}

/// Sign-in: lets background isolates manage this user's reminders.
final class ActivateReminderSession implements UseCase<Unit, NoParams> {
  const ActivateReminderSession(this._settings);

  final ReminderSettings _settings;

  @override
  Future<Result<Unit>> call(NoParams params) async {
    try {
      await _settings.setRemindersSessionActive(active: true);
      return const Ok(unit);
    } on Object catch (error, stackTrace) {
      return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
    }
  }
}
