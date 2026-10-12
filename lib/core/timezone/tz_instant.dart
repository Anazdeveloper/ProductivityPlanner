import 'package:timezone/timezone.dart' as tz;

/// [instant] as a `TZDateTime` in UTC, for platform APIs that require one
/// (local notification scheduling). Scheduling in UTC keeps reminders at a
/// fixed instant when the device's time zone changes.
///
/// `tz.UTC` is built in; the zone database does not need to be loaded.
tz.TZDateTime tzInstant(DateTime instant) =>
    tz.TZDateTime.from(instant.toUtc(), tz.UTC);
