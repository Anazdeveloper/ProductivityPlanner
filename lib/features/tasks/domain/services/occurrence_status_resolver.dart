import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

/// Works out the time-dependent status of an occurrence.
///
/// For a timed occurrence:
/// - `upcoming` before its start;
/// - `due` from the start for the planned duration (at least
///   [minimumDueWindow]);
/// - `overdue` after that, until its day ends;
/// - `missed` once its scheduled date is in the past.
///
/// An any-time occurrence is `upcoming` before its date, `due` on it and
/// `missed` after it.
final class OccurrenceStatusResolver {
  const OccurrenceStatusResolver();

  static const minimumDueWindow = Duration(minutes: 15);

  /// [today] is the current date in the series' time zone; [openSession] is
  /// the occurrence's running work session, if any.
  DerivedStatus resolve(
    TaskOccurrence occurrence, {
    required WorkSession? openSession,
    required DateTime now,
    required LocalDate today,
  }) {
    switch (occurrence.status) {
      case OccurrenceStatus.completed:
        return DerivedStatus.completed;
      case OccurrenceStatus.skipped:
        return DerivedStatus.skipped;
      case OccurrenceStatus.cancelled:
        return DerivedStatus.cancelled;
      case OccurrenceStatus.inProgress:
        return openSession != null
            ? DerivedStatus.inProgress
            : DerivedStatus.paused;
      case OccurrenceStatus.scheduled:
        return _scheduled(occurrence, now: now, today: today);
    }
  }

  DerivedStatus _scheduled(
    TaskOccurrence occurrence, {
    required DateTime now,
    required LocalDate today,
  }) {
    final date = occurrence.scheduledDate;
    if (date < today) return DerivedStatus.missed;
    if (date > today) return DerivedStatus.upcoming;

    final start = occurrence.scheduledStart;
    if (start == null) return DerivedStatus.due;
    if (now.isBefore(start)) return DerivedStatus.upcoming;

    final window = occurrence.plannedDuration > minimumDueWindow
        ? occurrence.plannedDuration
        : minimumDueWindow;
    return now.isBefore(start.add(window))
        ? DerivedStatus.due
        : DerivedStatus.overdue;
  }
}
