import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';

/// The quick choices offered when postponing ("in 1 hour", "tomorrow").
/// Pure; times are in the series' zone.
final class PostponeTargets {
  const PostponeTargets(this._converter);

  final TimeZoneConverter _converter;

  /// Rounded up to this many minutes, so "in 1 hour" lands on 15:45 rather
  /// than 15:43.
  static const roundToMinutes = 5;

  /// [delay] from [now]; null when that is no longer today (in the
  /// series' zone), or would not actually push the occurrence later (it is
  /// planned for a later time or day already).
  PostponeOccurrence? later(AgendaItem item, DateTime now, Duration delay) {
    final zone = _zoneOf(item);
    final occurrence = item.occurrence;
    final target = _roundUp(now.toUtc().add(delay));
    final today = _converter.localDate(now, zone);
    if (_converter.localDate(target, zone) != today) return null;
    if (occurrence.scheduledDate > today) return null;
    final start = occurrence.scheduledStart;
    if (occurrence.scheduledDate == today &&
        start != null &&
        !target.isAfter(start)) {
      return null;
    }
    return PostponeOccurrence(
      toDate: today,
      toTime: _converter.localTime(target, zone),
    );
  }

  /// The day after its current date (or after today, if that is already
  /// past), keeping its wall-clock time; any-time stays any-time.
  PostponeOccurrence tomorrow(AgendaItem item, DateTime now) {
    final zone = _zoneOf(item);
    final occurrence = item.occurrence;
    final today = _converter.localDate(now, zone);
    final base = maxDate(occurrence.scheduledDate, today);
    final start = occurrence.scheduledStart;
    return PostponeOccurrence(
      toDate: base.addDays(1),
      toTime: start == null ? null : _converter.localTime(start, zone),
    );
  }

  /// The series' zone, or UTC if this build's tz data does not know it.
  String _zoneOf(AgendaItem item) {
    final zone = item.task.schedule.timeZone;
    return _converter.isValidZone(zone) ? zone : 'UTC';
  }

  static DateTime _roundUp(DateTime instant) {
    const step = roundToMinutes * 60 * 1000;
    final millis = instant.millisecondsSinceEpoch;
    final remainder = millis % step;
    return DateTime.fromMillisecondsSinceEpoch(
      remainder == 0 ? millis : millis + step - remainder,
      isUtc: true,
    );
  }
}
