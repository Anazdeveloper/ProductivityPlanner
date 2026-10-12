import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A wall-clock time of day with minute precision and no zone, e.g. "09:30".
@immutable
final class LocalTime implements Comparable<LocalTime> {
  /// Throws [ArgumentError] outside 00:00–23:59.
  factory LocalTime(int hour, int minute) {
    if (!_valid(hour, minute)) {
      throw ArgumentError('Invalid time: $hour:$minute');
    }
    return LocalTime._(hour, minute);
  }

  const LocalTime._(this.hour, this.minute);

  /// Parses `HH:mm`. Throws [FormatException] otherwise.
  factory LocalTime.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) throw FormatException('Expected HH:mm', value);
    final hour = int.parse(match.group(1) ?? '');
    final minute = int.parse(match.group(2) ?? '');
    if (!_valid(hour, minute)) {
      throw FormatException('Time does not exist', value);
    }
    return LocalTime._(hour, minute);
  }

  static bool _valid(int hour, int minute) =>
      hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;

  /// Null for null or malformed input.
  static LocalTime? tryParse(String? value) {
    if (value == null) return null;
    try {
      return LocalTime.parse(value);
    } on FormatException {
      return null;
    }
  }

  static final _pattern = RegExp(r'^(\d{2}):(\d{2})$');

  final int hour;
  final int minute;

  int get minutesOfDay => hour * 60 + minute;

  @override
  int compareTo(LocalTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  bool operator ==(Object other) =>
      other is LocalTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  /// `HH:mm`: the wire and storage format.
  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
