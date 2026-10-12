import 'dart:async';

import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/reconcile_reminders.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

/// Keeps scheduled reminders in step with tasks, settings and the session
/// (main isolate). Joins auth, tasks and notifications, so it lives in the
/// composition root.
///
/// Reconciles when:
/// - a user signs in, and on every change to occurrences in the reminder
///   window (create, edit, postpone, complete, delete, sync), debounced;
/// - the reminders switch changes;
/// - the app returns to the foreground (permission may have changed in the
///   system settings, and the window has moved);
/// - the day changes while the app is open;
/// - a sync push arrives ([requestReconcile]).
///
/// The permission prompt is shown only right after the user saved a task
/// in the editor ([requestReconcile] with `allowPrompt`), with the app in
/// the foreground: in context, never at launch. Database changes alone
/// (materialization, sync, background buttons) never prompt.
///
/// Every signed-out state cancels all notifications: a signed-out phone
/// must not announce someone's tasks.
///
/// Auth changes are handled in order; reconciliations never overlap, and
/// requests during one coalesce into a single follow-up run.
final class ReminderSync {
  ReminderSync({
    required WatchAuthState watchAuthState,
    required WatchAgenda watchAgenda,
    required GetHomeToday getHomeToday,
    required ReconcileReminders reconcile,
    required ActivateReminderSession activate,
    required CancelAllReminders cancelAll,
    required PromptForRemindersIfNeeded promptIfNeeded,
    required WatchRemindersEnabled watchRemindersEnabled,
    required Ticker ticker,
    required AppLogger logger,
    required ErrorReporter reporter,
    this.debounce = const Duration(milliseconds: 400),
  }) : _watchAuthState = watchAuthState,
       _watchAgenda = watchAgenda,
       _getHomeToday = getHomeToday,
       _reconcile = reconcile,
       _activate = activate,
       _cancelAll = cancelAll,
       _promptIfNeeded = promptIfNeeded,
       _watchRemindersEnabled = watchRemindersEnabled,
       _ticker = ticker,
       _logger = logger,
       _reporter = reporter;

  final WatchAuthState _watchAuthState;
  final WatchAgenda _watchAgenda;
  final GetHomeToday _getHomeToday;
  final ReconcileReminders _reconcile;
  final ActivateReminderSession _activate;
  final CancelAllReminders _cancelAll;
  final PromptForRemindersIfNeeded _promptIfNeeded;
  final WatchRemindersEnabled _watchRemindersEnabled;
  final Ticker _ticker;
  final AppLogger _logger;
  final ErrorReporter _reporter;

  /// Collapses bursts of database changes (a split writes many rows).
  final Duration debounce;

  StreamSubscription<AuthState>? _auth;
  Future<void> _authQueue = Future.value();
  final List<StreamSubscription<Object?>> _active = [];
  StreamSubscription<Object?>? _window;
  Timer? _debounceTimer;
  LocalDate? _windowStart;
  String? _userId;

  bool _foreground = true;

  /// Set when the user saved a task; allows the permission prompt on the
  /// next run.
  bool _promptAllowed = false;
  bool _running = false;
  bool _rerun = false;
  Completer<void>? _runDone;

  /// Completes when no reconciliation is running or scheduled.
  Future<void> get idle async {
    await _authQueue;
    while (_running || _debounceTimer != null) {
      final done = _runDone;
      if (done != null) await done.future;
      await Future<void>.delayed(Duration.zero);
    }
  }

  void start() {
    _auth ??= _watchAuthState().listen(
      (state) => _authQueue = _authQueue.then((_) => _onAuth(state)),
    );
  }

  void appResumed() {
    _foreground = true;
    requestReconcile();
  }

  void appPaused() => _foreground = false;

  /// Schedules a reconciliation (debounced). No-op while signed out.
  void requestReconcile({bool allowPrompt = false}) {
    if (_userId == null) return;
    if (allowPrompt) _promptAllowed = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () {
      _debounceTimer = null;
      unawaited(_run());
    });
  }

  Future<void> _onAuth(AuthState state) async {
    try {
      switch (state) {
        case Authenticated(:final user):
          if (_userId == user.id) return;
          await _stop();
          _userId = user.id;
          await _activate(const NoParams());
          await _startWatching();
        case Unauthenticated():
          // Also on a cold start into a signed-out state: notifications
          // from a revoked session must go. Idempotent.
          _userId = null;
          await _stop();
          await _cancelAll(const NoParams());
        case AuthUnknown():
          break;
      }
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'reminders'});
    }
  }

  Future<void> _startWatching() async {
    _active
      ..add(_watchRemindersEnabled().listen((_) => requestReconcile()))
      ..add(_ticker.ticks().listen((_) => unawaited(_checkDay())));
    await _watchWindow();
  }

  /// (Re)subscribes to occurrences from yesterday to the horizon.
  Future<void> _watchWindow() async {
    final today = (await _getHomeToday(const NoParams())).valueOrNull;
    if (today == null || _userId == null) return;
    _windowStart = today;
    await _window?.cancel();
    _window = _watchAgenda(
      AgendaRange(
        from: today.addDays(-1),
        to: today.addDays(OccurrencePlanner.horizonDays),
      ),
    ).listen((_) => requestReconcile());
  }

  Future<void> _checkDay() async {
    final today = (await _getHomeToday(const NoParams())).valueOrNull;
    if (today == null || today == _windowStart || _userId == null) return;
    await _watchWindow();
  }

  /// Stops all triggers and waits for a running reconciliation, so nothing
  /// schedules after a sign-out's cancel.
  Future<void> _stop() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    for (final subscription in _active) {
      await subscription.cancel();
    }
    _active.clear();
    await _window?.cancel();
    _window = null;
    _windowStart = null;
    _promptAllowed = false;
    final done = _runDone;
    if (_running && done != null) await done.future;
  }

  Future<void> _run() async {
    if (_running) {
      _rerun = true;
      return;
    }
    _running = true;
    final done = _runDone = Completer<void>();
    try {
      do {
        _rerun = false;
        await _reconcileOnce();
      } while (_rerun && _userId != null);
    } finally {
      _running = false;
      done.complete();
    }
  }

  Future<void> _reconcileOnce() async {
    if (_userId == null) return;
    final result = await _reconcile(const NoParams());
    switch (result) {
      case Ok(value: final report):
        _logger.debug(
          'reminders reconciled',
          context: {
            'wanted': report.wanted,
            'scheduled': report.scheduled,
            'cancelled': report.cancelled,
            'kept': report.kept,
            'active': report.active,
          },
        );
        final mayPrompt = _promptAllowed && _foreground && _userId != null;
        _promptAllowed = false;
        if (mayPrompt) {
          final prompted = await _promptIfNeeded(report);
          if ((prompted.valueOrNull ?? false) && _userId != null) {
            await _reconcile(const NoParams());
          }
        }
      case Err(:final failure):
        await _reporter.report(
          failure,
          StackTrace.current,
          context: {'step': 'reconcile_reminders'},
        );
    }
  }

  Future<void> dispose() async {
    await _auth?.cancel();
    _auth = null;
    await _authQueue;
    await _stop();
  }
}
