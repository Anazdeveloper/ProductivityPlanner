import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_status_resolver.dart';

import '../../../helpers/agenda_builders.dart';

void main() {
  final summarizer = AgendaSummarizer(
    resolver: const OccurrenceStatusResolver(),
    converter: TzTimeZoneConverter(),
  );
  final today = LocalDate(2026, 10, 7);
  // 10:00 in Kolkata.
  final now = DateTime.utc(2026, 10, 7, 4, 30);

  test('entries carry status and the wall-clock start in the task zone', () {
    final entries = summarizer.entries([
      agendaItem(id: 'a', date: today, start: DateTime.utc(2026, 10, 7, 3, 30)),
      agendaItem(id: 'b', date: today, start: DateTime.utc(2026, 10, 7, 6, 30)),
      agendaItem(id: 'c', date: today),
    ], now);

    expect(entries.map((e) => e.status), [
      DerivedStatus.overdue,
      DerivedStatus.upcoming,
      DerivedStatus.due,
    ]);
    expect(entries[0].startTime, LocalTime(9, 0));
    expect(entries[1].startTime, LocalTime(12, 0));
    expect(entries[2].startTime, isNull);
  });

  test('"today" is per zone: late evening UTC is already tomorrow in Kolkata', () {
    final lateUtc = DateTime.utc(2026, 10, 7, 20); // 01:30 on the 8th in IST
    final entries = summarizer.entries([
      agendaItem(id: 'a', date: today),
      agendaItem(id: 'b', date: today, zone: 'America/New_York'),
    ], lateUtc);
    expect(entries[0].status, DerivedStatus.missed);
    expect(entries[1].status, DerivedStatus.due);
  });

  test('summary counts, times and progress ignore cancelled', () {
    final summary = summarizer.summarize(
      summarizer.entries([
        agendaItem(
          id: 'done',
          date: today,
          status: OccurrenceStatus.completed,
          actual: const Duration(minutes: 25),
        ),
        agendaItem(id: 'skip', date: today, status: OccurrenceStatus.skipped),
        agendaItem(
          id: 'gone',
          date: today,
          status: OccurrenceStatus.cancelled,
        ),
        agendaItem(id: 'todo', date: today, planned: const Duration(hours: 1)),
      ], now),
    );
    expect(summary.total, 3);
    expect(summary.completed, 1);
    expect(summary.skipped, 1);
    expect(summary.remaining, 1);
    expect(summary.planned, const Duration(hours: 2));
    expect(summary.tracked, const Duration(minutes: 25));
    expect(summary.progress, closeTo(1 / 3, 1e-9));
    expect(summary.next?.occurrenceId, 'todo');
  });

  test('next prefers running, then due, then overdue, then upcoming', () {
    final running = agendaItem(
      id: 'running',
      date: today,
      status: OccurrenceStatus.inProgress,
      sessions: [
        WorkSession(id: 'w', occurrenceId: 'running', startedAt: now),
      ],
    );
    final due = agendaItem(id: 'due', date: today);
    final overdue = agendaItem(
      id: 'overdue',
      date: today,
      start: DateTime.utc(2026, 10, 7, 2),
    );
    final upcoming = agendaItem(
      id: 'upcoming',
      date: today,
      start: DateTime.utc(2026, 10, 7, 8),
    );

    DaySummary summary(List<AgendaItem> items) =>
        summarizer.summarize(summarizer.entries(items, now));

    expect(summary([upcoming, overdue, due, running]).next?.occurrenceId, 'running');
    expect(summary([upcoming, overdue, due]).next?.occurrenceId, 'due');
    expect(summary([upcoming, overdue]).next?.occurrenceId, 'overdue');
    expect(summary([upcoming]).next?.occurrenceId, 'upcoming');
    expect(summarizer.summarize(const []).next, isNull);
  });
}
