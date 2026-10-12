import 'dart:async';
import 'dart:math' as math;

import 'package:productivity_planner/core/device/connectivity_monitor.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';

/// Decides when the sync engine runs. Never assumes the device is online:
/// every trigger only *tries*, and a failed run is retried with backoff.
///
/// Runs, while a user's data is ready:
/// - as soon as it is ready (sign-in, app start with a stored session);
/// - [debounce] after the outbox grows (a burst of edits is one push);
/// - when the app comes back to the foreground;
/// - when the network comes back;
/// - on [requestSync] (a `sync` push, the "Sync now" button);
/// - every [interval] while in the foreground;
/// - after a failure, with exponential backoff from [minBackoff] to
///   [maxBackoff] (none while offline: the network's return triggers).
final class SyncScheduler {
  SyncScheduler({
    required Stream<String?> Function() watchPreparedUser,
    required SyncEngine engine,
    required OutboxWriter outbox,
    required ConnectivityMonitor connectivity,
    required AppLogger logger,
    this.debounce = const Duration(seconds: 2),
    this.interval = const Duration(minutes: 15),
    this.minBackoff = const Duration(seconds: 30),
    this.maxBackoff = const Duration(minutes: 15),
  }) : _watchPreparedUser = watchPreparedUser,
       _engine = engine,
       _outbox = outbox,
       _connectivity = connectivity,
       _logger = logger;

  /// The user whose local data is ready (`UserSessionCoordinator`).
  final Stream<String?> Function() _watchPreparedUser;
  final SyncEngine _engine;
  final OutboxWriter _outbox;
  final ConnectivityMonitor _connectivity;
  final AppLogger _logger;
  final Duration debounce;
  final Duration interval;
  final Duration minBackoff;
  final Duration maxBackoff;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  String? _userId;
  bool _online = true;
  bool _foreground = true;
  bool _wasRunning = false;
  int? _pendingCount;
  int _failures = 0;
  Timer? _debounceTimer;

  /// The next periodic run or retry.
  Timer? _nextTimer;

  /// Consecutive failed runs (drives the backoff).
  int get failures => _failures;

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions
      ..add(_connectivity.watchOnline().listen(_onOnline))
      ..add(_engine.watch().listen(_onEngine))
      ..add(_outbox.watchPendingCount().listen(_onPendingCount))
      ..add(_watchPreparedUser().listen(_onUser));
  }

  void appResumed() {
    _foreground = true;
    _trigger('resume');
  }

  /// Leaving the foreground: no periodic runs, but a last push of what is
  /// queued while the OS still lets the app run.
  void appPaused() {
    _foreground = false;
    _cancelNext();
    if ((_pendingCount ?? 0) > 0) _trigger('pause');
  }

  /// Runs now (a `sync` push).
  void requestSync() => _trigger('request');

  void _onUser(String? userId) {
    _userId = userId;
    _failures = 0;
    _debounceTimer?.cancel();
    _cancelNext();
    if (userId != null) _trigger('session');
  }

  void _onOnline(bool online) {
    final regained = online && !_online;
    _online = online;
    if (regained) {
      _failures = 0;
      _trigger('online');
    }
  }

  void _onPendingCount(int count) {
    final previous = _pendingCount;
    _pendingCount = count;
    if (previous != null && count > previous && _userId != null) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounce, () => _trigger('changes'));
    }
  }

  /// Schedules what follows a run, however it was started (here or by
  /// the "Sync now" button).
  void _onEngine(SyncEngineState state) {
    final finished = _wasRunning && !state.running;
    _wasRunning = state.running;
    if (!finished || _userId == null) return;
    if (state.lastFailure == null) {
      _failures = 0;
      if (_foreground) _scheduleNext(interval, 'periodic');
      return;
    }
    _failures++;
    // Offline: the network's return triggers the next run.
    if (_online) _scheduleNext(backoffFor(_failures), 'retry');
  }

  /// [minBackoff] doubled per consecutive failure, at most [maxBackoff].
  Duration backoffFor(int failures) {
    final factor = math.pow(2, math.min(failures - 1, 20)).toInt();
    final delay = minBackoff * factor;
    return delay > maxBackoff ? maxBackoff : delay;
  }

  void _scheduleNext(Duration delay, String reason) {
    _cancelNext();
    _nextTimer = Timer(delay, () => _trigger(reason));
  }

  void _cancelNext() {
    _nextTimer?.cancel();
    _nextTimer = null;
  }

  void _trigger(String reason) {
    if (_userId == null) return;
    if (!_online) {
      _logger.debug('sync deferred: offline', context: {'reason': reason});
      return;
    }
    _debounceTimer?.cancel();
    _cancelNext();
    _logger.debug('sync', context: {'reason': reason});
    unawaited(_engine.sync());
  }

  Future<void> dispose() async {
    _userId = null;
    _debounceTimer?.cancel();
    _cancelNext();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _engine.idle;
  }
}
