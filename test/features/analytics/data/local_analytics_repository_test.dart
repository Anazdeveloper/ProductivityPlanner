import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/data/repositories/local_analytics_repository.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_task_repository.dart';

void main() {
  final today = LocalDate(2026, 10, 7);
  final t0 = DateTime.utc(2026, 10, 7, 4);

  test('maps an agenda item to its execution record', () {
    final item = agendaItem(
      id: 'o',
      date: today,
      title: 'Write',
      lineageId: 'write',
      start: t0,
      status: OccurrenceStatus.inProgress,
      planned: const Duration(minutes: 45),
      postponeCount: 1,
      actualStart: t0.add(const Duration(minutes: 5)),
      sessions: [
        WorkSession(
          id: 's1',
          occurrenceId: 'o',
          startedAt: t0.add(const Duration(minutes: 5)),
          endedAt: t0.add(const Duration(minutes: 25)),
        ),
        WorkSession(
          id: 's2',
          occurrenceId: 'o',
          startedAt: t0.add(const Duration(minutes: 40)),
        ),
      ],
    );

    final record = executionRecordFrom(item);

    expect(record.occurrenceId, 'o');
    expect(record.lineageId, 'write');
    expect(record.taskId, 'task-o');
    expect(record.title, 'Write');
    expect(record.timeZone, 'Asia/Kolkata');
    expect(record.date, today);
    expect(record.planned, const Duration(minutes: 45));
    expect(record.status, OccurrenceStatus.inProgress);
    expect(record.closedSessionTime, const Duration(minutes: 20));
    expect(record.openSessionStart, t0.add(const Duration(minutes: 40)));
    expect(record.startDelay, const Duration(minutes: 5));
    expect(record.postponeCount, 1);
    expect(
      record.sessionTime(t0.add(const Duration(minutes: 50))),
      const Duration(minutes: 30),
    );
  });

  test('watches a range and an activity through the task repository', () async {
    final tasks = FakeTaskRepository([
      agendaItem(id: 'a', date: today, lineageId: 'run'),
      agendaItem(id: 'b', date: today, lineageId: 'read'),
      agendaItem(id: 'c', date: today.addDays(9), lineageId: 'run'),
    ]);
    final repository = LocalAnalyticsRepository(tasks);

    final range = await repository
        .watchRecords(from: today, to: today.addDays(1))
        .first;
    expect(
      range.valueOrNull?.map((r) => r.occurrenceId),
      unorderedEquals(['a', 'b']),
    );

    final activity = await repository
        .watchActivity('run', from: today, to: today.addDays(30))
        .first;
    expect(
      activity.valueOrNull?.map((r) => r.occurrenceId),
      unorderedEquals(['a', 'c']),
    );
  });
}
