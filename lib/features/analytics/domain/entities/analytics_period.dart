import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/time/local_date.dart';

enum PeriodKind { day, week, month }

/// A calendar range analytics are shown for: one day, a Monday–Sunday week
/// (the planner's weeks) or a calendar month. Dates are inclusive.
@immutable
final class AnalyticsPeriod {
  const AnalyticsPeriod._(this.kind, this.start, this.end);

  /// The period of [kind] that contains [date].
  factory AnalyticsPeriod.containing(PeriodKind kind, LocalDate date) {
    switch (kind) {
      case PeriodKind.day:
        return AnalyticsPeriod._(kind, date, date);
      case PeriodKind.week:
        final monday = date.startOfIsoWeek;
        return AnalyticsPeriod._(kind, monday, monday.addDays(6));
      case PeriodKind.month:
        final first = LocalDate(date.year, date.month, 1);
        return AnalyticsPeriod._(
          kind,
          first,
          LocalDate(date.year, date.month, date.daysInMonth),
        );
    }
  }

  final PeriodKind kind;
  final LocalDate start;
  final LocalDate end;

  int get length => start.daysUntil(end) + 1;

  List<LocalDate> get days => [
    for (var i = 0; i < length; i++) start.addDays(i),
  ];

  bool contains(LocalDate date) => date >= start && date <= end;

  AnalyticsPeriod get previous =>
      AnalyticsPeriod.containing(kind, start.addDays(-1));

  AnalyticsPeriod get next => AnalyticsPeriod.containing(kind, end.addDays(1));

  /// A period of kind [other] around [around] if this period contains it,
  /// else around this period's start: switching Day/Week/Month keeps the
  /// place in time.
  AnalyticsPeriod withKind(PeriodKind other, {required LocalDate around}) =>
      AnalyticsPeriod.containing(other, contains(around) ? around : start);

  @override
  bool operator ==(Object other) =>
      other is AnalyticsPeriod &&
      other.kind == kind &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(kind, start, end);

  @override
  String toString() => 'AnalyticsPeriod(${kind.name}, $start..$end)';
}
