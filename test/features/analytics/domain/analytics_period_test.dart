import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';

void main() {
  final wednesday = LocalDate(2026, 10, 7);

  test('a week runs Monday to Sunday, like the planner', () {
    final week = AnalyticsPeriod.containing(PeriodKind.week, wednesday);
    expect(week.start, LocalDate(2026, 10, 5));
    expect(week.end, LocalDate(2026, 10, 11));
    expect(week.days, hasLength(7));
    expect(week.previous.start, LocalDate(2026, 9, 28));
    expect(week.next.start, LocalDate(2026, 10, 12));
  });

  test('a month is the calendar month, including February in leap years', () {
    final feb = AnalyticsPeriod.containing(PeriodKind.month, LocalDate(2028, 2, 10));
    expect(feb.start, LocalDate(2028, 2, 1));
    expect(feb.end, LocalDate(2028, 2, 29));
    expect(feb.length, 29);
    expect(feb.previous.end, LocalDate(2028, 1, 31));
    expect(feb.next.start, LocalDate(2028, 3, 1));
  });

  test('a day is one date', () {
    final day = AnalyticsPeriod.containing(PeriodKind.day, wednesday);
    expect(day.start, wednesday);
    expect(day.end, wednesday);
    expect(day.previous.start, LocalDate(2026, 10, 6));
  });

  test('switching kind keeps today when it is inside, else the start', () {
    final week = AnalyticsPeriod.containing(PeriodKind.week, wednesday);
    expect(
      week.withKind(PeriodKind.day, around: wednesday).start,
      wednesday,
    );
    final lastWeek = week.previous;
    expect(
      lastWeek.withKind(PeriodKind.day, around: wednesday).start,
      LocalDate(2026, 9, 28),
    );
    expect(
      lastWeek.withKind(PeriodKind.month, around: wednesday).start,
      LocalDate(2026, 9, 1),
    );
  });
}
