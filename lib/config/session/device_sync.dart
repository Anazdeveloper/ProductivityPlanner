import 'dart:async';

import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/notifications/domain/repositories/push_repositories.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/push.dart';

/// Keeps this install's server record (`PUT devices/{id}`) current: push
/// token, locale, zone and the reminders switch.
///
/// Registers on sign-in, on push-token refresh and when the reminders
/// switch changes, while signed in. On resume it registers again if the
/// last attempt failed (offline) or the last success is older than
/// [refreshAfter] (picks up a new device zone or locale after travel).
/// Signing out needs no call: `auth/logout` clears the token server-side
/// (contract §3.2).
final class DeviceSync {
  DeviceSync({
    required WatchAuthState watchAuthState,
    required PushMessaging push,
    required WatchRemindersEnabled watchRemindersEnabled,
    required RegisterDevice registerDevice,
    required Clock clock,
    required AppLogger logger,
    this.refreshAfter = const Duration(hours: 12),
  }) : _watchAuthState = watchAuthState,
       _push = push,
       _watchRemindersEnabled = watchRemindersEnabled,
       _registerDevice = registerDevice,
       _clock = clock,
       _logger = logger;

  final WatchAuthState _watchAuthState;
  final PushMessaging _push;
  final WatchRemindersEnabled _watchRemindersEnabled;
  final RegisterDevice _registerDevice;
  final Clock _clock;
  final AppLogger _logger;
  final Duration refreshAfter;
  DateTime? _lastSuccess;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  String? _userId;
  bool _needsRetry = false;
  Future<void> _pending = Future.value();

  /// Completes when queued registrations have finished.
  Future<void> get idle => _pending;

  void start() {
    if (_subscriptions.isNotEmpty) return;
    _subscriptions
      ..add(_watchAuthState().listen(_onAuth))
      ..add(_push.tokenRefreshes().listen((_) => _register()))
      // Skips the initial value: sign-in already registers.
      ..add(_watchRemindersEnabled().skip(1).listen((_) => _register()));
  }

  void appResumed() {
    final last = _lastSuccess;
    final stale =
        last == null || _clock.now().difference(last) >= refreshAfter;
    if (_needsRetry || (_userId != null && stale)) _register();
  }

  void _onAuth(AuthState state) {
    switch (state) {
      case Authenticated(:final user):
        if (_userId == user.id) return;
        _userId = user.id;
        _register();
      case Unauthenticated():
        _userId = null;
        _needsRetry = false;
        _lastSuccess = null;
      case AuthUnknown():
        break;
    }
  }

  void _register() {
    _pending = _pending.then((_) async {
      if (_userId == null) return;
      final result = await _registerDevice(const NoParams());
      _needsRetry = result.isErr;
      if (result.isOk) _lastSuccess = _clock.now();
      if (result case Err(:final failure)) {
        _logger.info(
          'device registration deferred',
          context: {'failure': failure.runtimeType.toString()},
        );
      }
    });
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _pending;
  }
}
