import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/services/recurrence_expander.dart';

/// Occurrences to insert for a series, and the new watermark.
final class MaterializationPlan {
  const MaterializationPlan({required this.occurrences, required this.through});

  final List<TaskOccurrence> occurrences;

  /// Store as the series' `materializedThrough`.
  final LocalDate through;
}

/// Decides which occurrences of a series should exist locally.
///
/// Occurrences are created a rolling [horizonDays] ahead so that reminders
/// can be scheduled and the planner can show the coming days offline. Ids
/// are deterministic, so inserting a planned occurrence that already exists
/// (from sync or an earlier run) must be a no-op (`insertOrIgnore`).
final class OccurrencePlanner {
  const OccurrencePlanner({
    required RecurrenceExpander expander,
    required TimeZoneConverter converter,
  }) : _expander = expander,
       _converter = converter;

  /// How far ahead occurrences exist.
  static const horizonDays = 14;

  /// How far back missed days are filled in when the app was not opened
  /// for a while (they show as missed and count in analytics).
  static const backfillDays = 30;

  final RecurrenceExpander _expander;
  final TimeZoneConverter _converter;

  /// The occurrences [task] still needs through `today + horizonDays`, or
  /// null when it is already materialized that far.
  ///
  /// [today] is the current date in the series' time zone.
  MaterializationPlan? plan(
    Task task, {
    required LocalDate today,
    required DateTime now,
  }) {
    final target = today.addDays(horizonDays);
    final watermark = task.materializedThrough;
    if (watermark != null && watermark >= target) return null;

    // A new series starts today at the earliest: creating a task never
    // produces occurrences that are already missed.
    final from = watermark == null
        ? maxDate(task.schedule.startDate, today)
        : maxDate(watermark.addDays(1), today.addDays(-backfillDays));

    final last = task.lastPossibleDate;
    final to = last == null ? target : minDate(target, last);

    final dates = from > to
        ? const <LocalDate>[]
        : _expander.expand(
            task.schedule.rule,
            task.schedule.startDate,
            from: from,
            to: to,
          );

    return MaterializationPlan(
      occurrences: [for (final date in dates) build(task, date, now: now)],
      through: target,
    );
  }

  /// The occurrence the rule produces for [task] on [date].
  TaskOccurrence build(Task task, LocalDate date, {required DateTime now}) {
    final time = task.schedule.startTime;
    final start = time == null
        ? null
        : _converter.toUtc(date, time, task.schedule.timeZone);
    return TaskOccurrence(
      id: occurrenceIdFor(
        seriesId: task.id,
        originalLocalDate: date.toDateTimeUtc(),
      ),
      seriesId: task.id,
      originalDate: date,
      scheduledDate: date,
      scheduledStart: start,
      originalStart: start,
      plannedDuration: task.plannedDuration,
      createdAt: now,
      updatedAt: now,
    );
  }
}
