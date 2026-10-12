import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';

/// Converts between wall-clock times in IANA zones and UTC instants.
///
/// An interface so domain code stays pure Dart; the implementation uses the
/// bundled tz database (`core/timezone`).
///
/// DST rules (shared with the server, vectors in
/// `contracts/vectors/zone_resolution.json`):
/// - A time skipped by spring-forward moves forward by the gap
///   (02:30 on a 02:00→03:00 night becomes 03:30).
/// - A time repeated by fall-back resolves to the first instant.
abstract interface class TimeZoneConverter {
  /// The UTC instant of [time] on [date] in [zone].
  ///
  /// Throws [ArgumentError] for an unknown zone; check [isValidZone] first
  /// for user or server input.
  DateTime toUtc(LocalDate date, LocalTime time, String zone);

  /// The calendar date in [zone] at [instant].
  LocalDate localDate(DateTime instant, String zone);

  /// The wall-clock time in [zone] at [instant] (seconds truncated).
  LocalTime localTime(DateTime instant, String zone);

  bool isValidZone(String zone);
}
