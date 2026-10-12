import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';

import '../../../helpers/agenda_builders.dart';

void main() {
  const timer = WorkTimer();
  final t0 = DateTime.utc(2026, 10, 7, 9);
  final today = LocalDate(2026, 10, 7);

  WorkSession session(String id, int startMin, [int? endMin]) => WorkSession(
    id: id,
    occurrenceId: 'o',
    startedAt: t0.add(Duration(minutes: startMin)),
    endedAt: endMin == null ? null : t0.add(Duration(minutes: endMin)),
  );

  group('snapshot', () {
    test('null before the first start', () {
      final item = agendaItem(id: 'o', date: today);
      expect(timer.snapshot(item, t0), isNull);
    });

    test('running: all sessions plus the open one up to now', () {
      final item = agendaItem(
        id: 'o',
        date: today,
        status: OccurrenceStatus.inProgress,
        sessions: [session('a', 0, 10), session('b', 20)],
      );
      final snap = timer.snapshot(item, t0.add(const Duration(minutes: 35)));

      expect(snap?.running, isTrue);
      expect(snap?.tracked, const Duration(minutes: 25));
      expect(snap?.currentSession, const Duration(minutes: 15));
      expect(snap?.remaining, const Duration(minutes: 5));
      expect(snap?.overrun, isFalse);
      expect(snap?.progress, closeTo(25 / 30, 1e-9));
    });

    test('paused: time stands still', () {
      final item = agendaItem(
        id: 'o',
        date: today,
        status: OccurrenceStatus.inProgress,
        sessions: [session('a', 0, 40)],
      );
      final later = timer.snapshot(item, t0.add(const Duration(hours: 5)));
      expect(later?.running, isFalse);
      expect(later?.tracked, const Duration(minutes: 40));
      expect(later?.currentSession, Duration.zero);
      expect(later?.overrun, isTrue);
      expect(later?.remaining, const Duration(minutes: -10));
      expect(later?.progress, 1);
    });
  });

  group('isImplausible', () {
    test('a forgotten timer on a short task', () {
      const planned = Duration(minutes: 30);
      // Limit is max(3 × 30 min, 30 min + 2 h) = 2 h 30 min.
      expect(timer.isImplausible(const Duration(hours: 2), planned), isFalse);
      expect(
        timer.isImplausible(const Duration(hours: 2, minutes: 31), planned),
        isTrue,
      );
    });

    test('long tasks get proportionally more room, up to 12 h', () {
      const planned = Duration(hours: 3);
      expect(timer.isImplausible(const Duration(hours: 9), planned), isFalse);
      expect(
        timer.isImplausible(const Duration(hours: 9, minutes: 1), planned),
        isTrue,
      );
      expect(
        timer.isImplausible(const Duration(hours: 12, minutes: 1),
            const Duration(hours: 6)),
        isTrue,
      );
    });
  });

  test('active work prefers the running occurrence, then the latest pause', () {
    final paused = agendaItem(
      id: 'paused',
      date: today,
      status: OccurrenceStatus.inProgress,
      sessions: [session('p', 0, 30)],
    );
    final pausedEarlier = agendaItem(
      id: 'earlier',
      date: today,
      status: OccurrenceStatus.inProgress,
      sessions: [session('e', 0, 10)],
    );
    final running = agendaItem(
      id: 'running',
      date: today,
      status: OccurrenceStatus.inProgress,
      sessions: [session('r', 40)],
    );

    expect(pickActiveWork([pausedEarlier, paused])?.occurrence.id, 'paused');
    expect(
      pickActiveWork([paused, running, pausedEarlier])?.occurrence.id,
      'running',
    );
    expect(pickActiveWork(const []), isNull);
  });
}
