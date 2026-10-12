import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_status_resolver.dart';

void main() {
  const resolver = OccurrenceStatusResolver();
  final today = LocalDate(2026, 10, 7);
  final start = DateTime.utc(2026, 10, 7, 9);

  TaskOccurrence occurrence({
    LocalDate? date,
    DateTime? scheduledStart,
    bool anyTime = false,
    OccurrenceStatus status = OccurrenceStatus.scheduled,
    Duration planned = const Duration(minutes: 30),
  }) => TaskOccurrence(
    id: 'o',
    seriesId: 's',
    originalDate: date ?? today,
    scheduledDate: date ?? today,
    scheduledStart: anyTime ? null : scheduledStart ?? start,
    plannedDuration: planned,
    status: status,
    createdAt: start,
    updatedAt: start,
  );

  DerivedStatus at(
    TaskOccurrence o,
    DateTime now, {
    WorkSession? openSession,
  }) => resolver.resolve(o, openSession: openSession, now: now, today: today);

  test('timed: upcoming → due → overdue', () {
    final o = occurrence();
    expect(at(o, start.subtract(const Duration(minutes: 1))), DerivedStatus.upcoming);
    expect(at(o, start), DerivedStatus.due);
    expect(at(o, start.add(const Duration(minutes: 29))), DerivedStatus.due);
    expect(at(o, start.add(const Duration(minutes: 30))), DerivedStatus.overdue);
  });

  test('a short task is due for at least the minimum window', () {
    final o = occurrence(planned: const Duration(minutes: 5));
    expect(at(o, start.add(const Duration(minutes: 10))), DerivedStatus.due);
    expect(at(o, start.add(const Duration(minutes: 15))), DerivedStatus.overdue);
  });

  test('a past day is missed; a future day is upcoming', () {
    expect(
      at(occurrence(date: today.addDays(-1)), start),
      DerivedStatus.missed,
    );
    expect(
      at(occurrence(date: today.addDays(1)), start),
      DerivedStatus.upcoming,
    );
  });

  test('any-time tasks are due all day', () {
    expect(at(occurrence(anyTime: true), start), DerivedStatus.due);
    expect(
      at(occurrence(anyTime: true, date: today.addDays(-1)), start),
      DerivedStatus.missed,
    );
  });

  test('in progress is running or paused depending on the open session', () {
    final o = occurrence(status: OccurrenceStatus.inProgress);
    final session = WorkSession(id: 'w', occurrenceId: 'o', startedAt: start);
    expect(at(o, start, openSession: session), DerivedStatus.inProgress);
    expect(at(o, start), DerivedStatus.paused);
  });

  test('resolved states are reported as stored', () {
    expect(
      at(occurrence(status: OccurrenceStatus.completed), start),
      DerivedStatus.completed,
    );
    expect(
      at(occurrence(status: OccurrenceStatus.skipped), start),
      DerivedStatus.skipped,
    );
    expect(
      at(occurrence(status: OccurrenceStatus.cancelled), start),
      DerivedStatus.cancelled,
    );
  });
}
