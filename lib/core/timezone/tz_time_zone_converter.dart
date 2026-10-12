import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// [TimeZoneConverter] backed by the IANA database bundled with the
/// `timezone` package, so results do not depend on the device's zone or
/// its OS tz data.
///
/// The database is loaded on first use (one-off, a few milliseconds).
final class TzTimeZoneConverter implements TimeZoneConverter {
  TzTimeZoneConverter();

  static bool _initialized = false;

  // The real instant is `naive - offset` and offsets span -12h..+14h, so
  // probe just outside that window on both sides.
  static const _probeBefore = Duration(hours: 15);
  static const _probeAfter = Duration(hours: 13);

  static void _ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }

  tz.Location _location(String zone) {
    _ensureInitialized();
    try {
      return tz.getLocation(zone);
    } on Exception {
      throw ArgumentError.value(zone, 'zone', 'Unknown IANA time zone');
    }
  }

  /// Offset of [location] at [utcMillis], in milliseconds.
  static int _offsetAt(tz.Location location, int utcMillis) => tz.TZDateTime
    .fromMillisecondsSinceEpoch(location, utcMillis)
    .timeZoneOffset
    .inMilliseconds;

  @override
  DateTime toUtc(LocalDate date, LocalTime time, String zone) {
    final location = _location(zone);
    // The wall-clock fields read as if they were UTC.
    final naive = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).millisecondsSinceEpoch;

    // Any transition near this wall time is between these two offsets
    // (no zone changes offset twice within 28 hours).
    final before = _offsetAt(location, naive - _probeBefore.inMilliseconds);
    final after = _offsetAt(location, naive + _probeAfter.inMilliseconds);

    int? earliestValid;
    for (final offset in {before, after}) {
      final candidate = naive - offset;
      if (_offsetAt(location, candidate) == offset &&
          (earliestValid == null || candidate < earliestValid)) {
        earliestValid = candidate;
      }
    }
    // No valid candidate means the wall time falls in a spring-forward gap:
    // applying the pre-transition offset moves it forward by the gap.
    final millis = earliestValid ?? naive - before;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  @override
  LocalDate localDate(DateTime instant, String zone) =>
      LocalDate.fromDateTime(_wallClock(instant, zone));

  @override
  LocalTime localTime(DateTime instant, String zone) {
    final wall = _wallClock(instant, zone);
    return LocalTime(wall.hour, wall.minute);
  }

  /// [instant] shifted by the zone's offset, with the wall-clock fields
  /// readable as if it were UTC.
  DateTime _wallClock(DateTime instant, String zone) {
    final location = _location(zone);
    final utcMillis = instant.toUtc().millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(
      utcMillis + _offsetAt(location, utcMillis),
      isUtc: true,
    );
  }

  @override
  bool isValidZone(String zone) {
    _ensureInitialized();
    try {
      tz.getLocation(zone);
      return true;
    } on Exception {
      return false;
    }
  }
}
