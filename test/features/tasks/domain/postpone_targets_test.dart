import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/services/postpone_targets.dart';

import '../../../helpers/agenda_builders.dart';

void main() {
  final targets = PostponeTargets(TzTimeZoneConverter());
  final today = LocalDate(2026, 10, 7);
  // 09:00 in Kolkata.
  final nine = DateTime.utc(2026, 10, 7, 3, 30);

  group('later', () {
    test('one hour from now, rounded up to 5 minutes, in the task zone', () {
      final item = agendaItem(id: 'a', date: today, start: nine);
      final action = targets.later(
        item,
        nine.add(const Duration(minutes: 2)),
        const Duration(hours: 1),
      );
      expect(action?.toDate, today);
      expect(action?.toTime, LocalTime(10, 5));
    });

    test('never moves a task earlier or pulls a later day into today', () {
      final afternoon = agendaItem(
        id: 'a',
        date: today,
        start: DateTime.utc(2026, 10, 7, 9, 30), // 15:00 IST
      );
      expect(targets.later(afternoon, nine, const Duration(hours: 1)), isNull);
      final nextWeek = agendaItem(id: 'b', date: today.addDays(7));
      expect(targets.later(nextWeek, nine, const Duration(hours: 1)), isNull);
    });

    test('is unavailable when it would cross midnight', () {
      final item = agendaItem(id: 'a', date: today, start: nine);
      // 23:30 in Kolkata.
      final late = DateTime.utc(2026, 10, 7, 18);
      expect(targets.later(item, late, const Duration(hours: 1)), isNull);
    });
  });

  group('tomorrow', () {
    test('keeps the wall-clock time', () {
      final item = agendaItem(id: 'a', date: today, start: nine);
      final action = targets.tomorrow(item, nine);
      expect(action.toDate, LocalDate(2026, 10, 8));
      expect(action.toTime, LocalTime(9, 0));
    });

    test('an overdue day moves to tomorrow, not the day after it', () {
      final item = agendaItem(id: 'a', date: today.addDays(-3));
      final action = targets.tomorrow(item, nine);
      expect(action.toDate, LocalDate(2026, 10, 8));
      expect(action.toTime, isNull);
    });
  });
}
