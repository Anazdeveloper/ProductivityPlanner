import 'dart:async';

import 'package:productivity_planner/core/database/user_data_store.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';

/// Keeps local data in step with the session. Lives in the composition root
/// because it joins two features (auth and tasks) that must not know each
/// other.
///
/// - Signed in: binds the database to the user (wiping another user's
///   data), seeds default categories and tops up occurrences.
/// - Signed out by the user: deletes the user's local data, unless it holds
///   changes not yet pushed (kept until a different user signs in).
/// - Session expired: keeps the data. The same user usually signs back in,
///   and unsynced changes survive; a different user triggers the wipe on
///   bind.
///
/// State changes are handled one at a time, in order. [watchPreparedUser]
/// tells the sync scheduler when the data is ready.
final class UserSessionCoordinator {
  UserSessionCoordinator({
    required WatchAuthState watchAuthState,
    required UserDataStore userData,
    required EnsureDefaultCategories ensureDefaultCategories,
    required EnsureOccurrencesMaterialized ensureOccurrences,
    required SyncEngine syncEngine,
    required AppLogger logger,
    required ErrorReporter reporter,
  }) : _watchAuthState = watchAuthState,
       _userData = userData,
       _ensureDefaultCategories = ensureDefaultCategories,
       _ensureOccurrences = ensureOccurrences,
       _syncEngine = syncEngine,
       _logger = logger,
       _reporter = reporter;

  final WatchAuthState _watchAuthState;
  final UserDataStore _userData;
  final EnsureDefaultCategories _ensureDefaultCategories;
  final EnsureOccurrencesMaterialized _ensureOccurrences;
  final SyncEngine _syncEngine;
  final AppLogger _logger;
  final ErrorReporter _reporter;

  StreamSubscription<AuthState>? _subscription;
  Future<void> _pending = Future.value();
  String? _preparedUserId;
  final _prepared = StreamController<String?>.broadcast(sync: true);

  /// Completes when every state received so far has been handled.
  Future<void> get idle => _pending;

  /// The user whose local data is ready (bound, seeded); null while
  /// signed out.
  String? get preparedUserId => _preparedUserId;

  /// [preparedUserId] first, then every change. Sync runs only while it
  /// is non-null, so it never writes into a database bound to nobody.
  Stream<String?> watchPreparedUser() => Stream<String?>.multi((c) {
    c.add(_preparedUserId);
    final subscription = _prepared.stream.listen(c.add);
    c.onCancel = subscription.cancel;
  });

  /// Call once, before the session is restored, so the first state is seen.
  void start() {
    _subscription ??= _watchAuthState().listen(
      (state) => _pending = _pending.then((_) => _handle(state)),
    );
  }

  /// The app came back to the foreground: the 14-day planning horizon has
  /// moved with the calendar, so top occurrences up (idempotent and cheap
  /// when nothing is missing). Ignored while signed out.
  void appResumed() {
    _pending = _pending.then((_) async {
      if (_preparedUserId == null) return;
      try {
        final created = await _ensureOccurrences(const NoParams());
        _logger.debug(
          'occurrences topped up on resume',
          context: {'created': created.valueOrNull},
        );
      } on Object catch (error, stackTrace) {
        await _reporter.report(error, stackTrace, context: {'step': 'resume'});
      }
    });
  }

  /// Stops listening and waits for the state being handled, so the
  /// database is not closed underneath it.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _pending;
    _syncEngine.enabled = false;
    await _prepared.close();
  }

  Future<void> _handle(AuthState state) async {
    try {
      switch (state) {
        case Authenticated(:final user):
          await _prepareFor(user.id);
        case Unauthenticated(reason: SignOutReason.userSignedOut):
          _setPrepared(null);
          // A run in flight would write rows back after the wipe.
          await _syncEngine.idle;
          final cleared = await _userData.clearUserDataIfSynced();
          _logger.info(
            cleared
                ? 'local user data cleared after sign-out'
                : 'local user data kept after sign-out: unsynced changes',
          );
        case Unauthenticated():
          _setPrepared(null);
        case AuthUnknown():
          break;
      }
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'session'});
    }
  }

  Future<void> _prepareFor(String userId) async {
    // Profile updates re-emit Authenticated for the same user.
    if (_preparedUserId == userId) return;
    // A previous user's run must not write into the rebound database.
    await _syncEngine.idle;
    final wiped = await _userData.bindToUser(userId);
    if (wiped) {
      // Includes any of their unsynced changes: there is nowhere to keep
      // two users' data apart.
      _logger.warning('local data of a previous user deleted');
    }

    try {
      final seeded = await _ensureDefaultCategories(userId);
      final materialized = await _ensureOccurrences(const NoParams());
      _logger.info(
        'local data ready',
        context: {
          'categories_ok': seeded.isOk,
          'occurrences_created': materialized.valueOrNull,
        },
      );
    } finally {
      // Bound is enough to work and sync, even if seeding failed.
      _setPrepared(userId);
    }
  }

  /// Also the sync gate: the engine runs only while a user is prepared
  /// (covers "Sync now" as well as the scheduler).
  void _setPrepared(String? userId) {
    _syncEngine.enabled = userId != null;
    if (_preparedUserId == userId) return;
    _preparedUserId = userId;
    _prepared.add(userId);
  }
}
