/// Source of "now". Injected everywhere time matters (lifecycle, timers,
/// derived states, reminders) so tests can freeze or advance time.
abstract interface class Clock {
  /// Current instant in UTC.
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}
