import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

/// Turns a recurrence rule into local dates.
///
/// Must produce exactly what the server produces; both are checked against
/// `contracts/vectors/recurrence.json`. Semantics are documented on
/// [RecurrenceRule].
final class RecurrenceExpander {
  const RecurrenceExpander();

  /// Dates in `[from, to]` (inclusive), ascending.
  List<LocalDate> expand(
    RecurrenceRule rule,
    LocalDate start, {
    required LocalDate from,
    required LocalDate to,
  }) {
    final until = rule.until;
    final count = rule.count;
    final result = <LocalDate>[];
    var emitted = 0;
    for (final date in _candidates(rule, start, to)) {
      if (date > to) break;
      if (until != null && date > until) break;
      if (count != null && emitted >= count) break;
      emitted++;
      if (date >= from) result.add(date);
    }
    return result;
  }

  /// Dates the rule produces from [start], ascending, stopping soon after
  /// [to]. `count` and `until` are applied by the caller.
  Iterable<LocalDate> _candidates(
    RecurrenceRule rule,
    LocalDate start,
    LocalDate to,
  ) sync* {
    final interval = rule.interval < 1 ? 1 : rule.interval;
    switch (rule.frequency) {
      case RecurrenceFrequency.none:
        yield start;

      case RecurrenceFrequency.daily:
        for (var date = start; date <= to; date = date.addDays(interval)) {
          yield date;
        }

      case RecurrenceFrequency.weekly:
        final weekdays = rule.weekdays.isEmpty
            ? [start.weekday]
            : ({...rule.weekdays}.toList()..sort());
        for (
          var monday = start.startOfIsoWeek;
          monday <= to;
          monday = monday.addDays(7 * interval)
        ) {
          for (final weekday in weekdays) {
            final date = monday.addDays(weekday - 1);
            if (date >= start) yield date;
          }
        }

      case RecurrenceFrequency.monthly:
        final day = rule.monthDay ?? start.day;
        var year = start.year;
        var month = start.month;
        while (LocalDate(year, month, 1) <= to) {
          final firstOfMonth = LocalDate(year, month, 1);
          if (day <= firstOfMonth.daysInMonth) {
            final date = LocalDate(year, month, day);
            if (date >= start) yield date;
          }
          month += interval;
          while (month > 12) {
            month -= 12;
            year++;
          }
        }
    }
  }
}
