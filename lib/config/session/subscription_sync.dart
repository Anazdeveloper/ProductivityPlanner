import 'dart:async';

import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/subscription/domain/repositories/subscription_repository.dart';

/// Keeps the entitlement tied to the signed-in user: binds purchases and
/// the cached entitlement on sign-in and asks the server; back to free on
/// sign-out. On resume it asks again when the last answer is older than
/// [refreshAfter], failed, or a purchase is still unconfirmed.
final class SubscriptionSync {
  SubscriptionSync({
    required WatchAuthState watchAuthState,
    required SubscriptionRepository subscriptions,
    required Clock clock,
    required AppLogger logger,
    this.refreshAfter = const Duration(hours: 6),
  }) : _watchAuthState = watchAuthState,
       _subscriptions = subscriptions,
       _clock = clock,
       _logger = logger;

  final WatchAuthState _watchAuthState;
  final SubscriptionRepository _subscriptions;
  final Clock _clock;
  final AppLogger _logger;
  final Duration refreshAfter;

  StreamSubscription<AuthState>? _auth;
  String? _userId;
  DateTime? _lastSuccess;
  Future<void> _pending = Future.value();

  /// Completes when queued work has finished.
  Future<void> get idle => _pending;

  void start() {
    _auth ??= _watchAuthState().listen(_onAuth);
  }

  void appResumed() {
    if (_userId == null) return;
    final last = _lastSuccess;
    final stale =
        last == null || _clock.now().difference(last) >= refreshAfter;
    if (stale || !_subscriptions.current.verified) _queue(_refresh);
  }

  /// After a `subscription` push or a purchase made on another device.
  void refreshNow() {
    if (_userId != null) _queue(_refresh);
  }

  void _onAuth(AuthState state) {
    switch (state) {
      case Authenticated(:final user):
        if (_userId == user.id) return;
        _userId = user.id;
        _lastSuccess = null;
        _queue(() async {
          await _subscriptions.bindUser(user.id);
          await _refresh();
        });
      case Unauthenticated():
        if (_userId == null) return;
        _userId = null;
        _lastSuccess = null;
        _queue(_subscriptions.unbindUser);
      case AuthUnknown():
        break;
    }
  }

  Future<void> _refresh() async {
    if (_userId == null) return;
    final result = await _subscriptions.refresh();
    switch (result) {
      case Ok():
        _lastSuccess = _clock.now();
      case Err(:final failure):
        _logger.info(
          'entitlement refresh deferred',
          context: {'failure': failure.runtimeType.toString()},
        );
    }
  }

  /// Runs [work] after what is queued; a failure is logged and never
  /// blocks the steps after it.
  void _queue(Future<void> Function() work) {
    _pending = _pending.then((_) => work()).catchError(
      (Object error, StackTrace stackTrace) => _logger.warning(
        'subscription sync step failed',
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  Future<void> dispose() async {
    await _auth?.cancel();
    _auth = null;
    await _pending;
  }
}
