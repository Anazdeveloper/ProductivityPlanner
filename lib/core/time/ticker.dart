import 'dart:async';

import 'package:productivity_planner/core/time/clock.dart';

/// Emits the current time periodically, so screens can refresh
/// time-dependent state (due → overdue, a new day) without polling the
/// database. Injected so tests drive time explicitly.
abstract interface class Ticker {
  /// The current instant (UTC) on every tick. Each listener gets its own
  /// timer, cancelled when the subscription is.
  Stream<DateTime> ticks();
}

final class PeriodicTicker implements Ticker {
  const PeriodicTicker(
    this._clock, {
    this.interval = const Duration(seconds: 30),
  });

  final Clock _clock;

  /// Half a minute keeps minute-level labels at most 30 s stale.
  final Duration interval;

  @override
  Stream<DateTime> ticks() => Stream.periodic(interval, (_) => _clock.now());
}
