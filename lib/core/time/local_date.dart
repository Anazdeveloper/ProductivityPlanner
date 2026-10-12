import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A calendar date with no time and no zone, e.g. the day a task is planned
/// for in the task's own time zone.
///
/// Pure Dart. Arithmetic goes through UTC `DateTime`s, which have no DST, so
/// adding a day always lands on the next calendar date.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  /// Throws [ArgumentError] for dates that do not exist (e.g. 2026-02-30).
  factory LocalDate(int year, int month, int day) {
    if (!_exists(year, month, day)) {
      throw ArgumentError('Invalid date: $year-$month-$day');
    }
    return LocalDate._(year, month, day);
  }

  const LocalDate._(this.year, this.month, this.day);

  /// The calendar fields of [dateTime], ignoring its zone and time.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate._(dateTime.year, dateTime.month, dateTime.day);

  /// Parses `YYYY-MM-DD`. Throws [FormatException] otherwise.
  factory LocalDate.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) throw FormatException('Expected YYYY-MM-DD', value);
    final year = int.parse(match.group(1) ?? '');
    final month = int.parse(match.group(2) ?? '');
    final day = int.parse(match.group(3) ?? '');
    if (!_exists(year, month, day)) {
      throw FormatException('Date does not exist', value);
    }
    return LocalDate._(year, month, day);
  }

  static bool _exists(int year, int month, int day) {
    final normalized = DateTime.utc(year, month, day);
    return normalized.year == year &&
        normalized.month == month &&
        normalized.day == day;
  }

  /// Null for null or malformed input.
  static LocalDate? tryParse(String? value) {
    if (value == null) return null;
    try {
      return LocalDate.parse(value);
    } on FormatException {
      return null;
    }
  }

  static final _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  DateTime _utc() => DateTime.utc(year, month, day);

  /// Midnight UTC on this date. Only for calendar maths and ids, never as an
  /// instant in time.
  DateTime toDateTimeUtc() => _utc();

  /// ISO weekday: 1 = Monday … 7 = Sunday.
  int get weekday => _utc().weekday;

  /// Number of days in this date's month.
  int get daysInMonth => DateTime.utc(year, month + 1, 0).day;

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(_utc().add(Duration(days: days)));

  /// The Monday of this date's ISO week.
  LocalDate get startOfIsoWeek => addDays(1 - weekday);

  /// Whole days from this date to [other] (negative if [other] is earlier).
  int daysUntil(LocalDate other) => other._utc().difference(_utc()).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;

  bool isAfter(LocalDate other) => compareTo(other) > 0;

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  bool operator <(LocalDate other) => compareTo(other) < 0;

  bool operator <=(LocalDate other) => compareTo(other) <= 0;

  bool operator >(LocalDate other) => compareTo(other) > 0;

  bool operator >=(LocalDate other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  /// `YYYY-MM-DD`: the wire and storage format. Sorts lexicographically.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}

/// The later of two dates.
LocalDate maxDate(LocalDate a, LocalDate b) => a >= b ? a : b;

/// The earlier of two dates.
LocalDate minDate(LocalDate a, LocalDate b) => a <= b ? a : b;
