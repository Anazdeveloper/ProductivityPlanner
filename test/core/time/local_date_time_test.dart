import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';

void main() {
  group('LocalDate', () {
    test('parses and formats YYYY-MM-DD', () {
      final date = LocalDate.parse('2026-02-03');
      expect([date.year, date.month, date.day], [2026, 2, 3]);
      expect(date.toString(), '2026-02-03');
    });

    test('rejects malformed and impossible dates', () {
      expect(() => LocalDate.parse('2026-2-3'), throwsFormatException);
      expect(() => LocalDate.parse('2026-02-30'), throwsFormatException);
      expect(() => LocalDate(2026, 13, 1), throwsArgumentError);
      expect(LocalDate.tryParse('nope'), isNull);
      expect(LocalDate.tryParse(null), isNull);
    });

    test('addDays crosses months, years and DST without drifting', () {
      expect(LocalDate(2026, 12, 31).addDays(1), LocalDate(2027, 1, 1));
      expect(LocalDate(2028, 2, 28).addDays(1), LocalDate(2028, 2, 29));
      // A DST night in most zones; LocalDate has no zone, so nothing moves.
      expect(LocalDate(2026, 3, 28).addDays(2), LocalDate(2026, 3, 30));
      expect(LocalDate(2026, 1, 1).addDays(-1), LocalDate(2025, 12, 31));
    });

    test('ISO weekday, week start and days in month', () {
      final wednesday = LocalDate(2026, 10, 7);
      expect(wednesday.weekday, DateTime.wednesday);
      expect(wednesday.startOfIsoWeek, LocalDate(2026, 10, 5));
      expect(LocalDate(2026, 10, 11).startOfIsoWeek, LocalDate(2026, 10, 5));
      expect(LocalDate(2026, 2, 1).daysInMonth, 28);
      expect(LocalDate(2028, 2, 1).daysInMonth, 29);
    });

    test('ordering and daysUntil', () {
      final a = LocalDate(2026, 10, 7);
      final b = LocalDate(2026, 11, 7);
      expect(a < b, isTrue);
      expect(a.daysUntil(b), 31);
      expect(b.daysUntil(a), -31);
      expect(minDate(a, b), a);
      expect(maxDate(a, b), b);
      expect(LocalDate(2026, 10, 7), a);
    });
  });

  group('LocalTime', () {
    test('parses, formats and compares', () {
      final time = LocalTime.parse('07:05');
      expect(time.toString(), '07:05');
      expect(time.minutesOfDay, 425);
      expect(LocalTime(9, 0).compareTo(time), greaterThan(0));
    });

    test('rejects invalid times', () {
      expect(() => LocalTime.parse('24:00'), throwsFormatException);
      expect(() => LocalTime.parse('7:05'), throwsFormatException);
      expect(LocalTime.tryParse('xx'), isNull);
    });
  });
}
