import 'dart:async';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/device/device_id_provider.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/dio_failure_mapper.dart';
import 'package:productivity_planner/core/sync/sync_entity_handler.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';
import 'package:productivity_planner/core/sync/sync_remote_data_source.dart';
import 'package:productivity_planner/core/sync/sync_stores.dart';
import 'package:productivity_planner/core/time/clock.dart';

/// What the engine is doing and how the last run went.
@immutable
final class SyncEngineState {
  const SyncEngineState({
    this.running = false,
    this.lastSuccessAt,
    this.lastFailure,
  });

  final bool running;
  final DateTime? lastSuccessAt;

  /// Why the last run stopped early; null after a successful run.
  final Failure? lastFailure;

  SyncEngineState copyWith({
    bool? running,
    DateTime? lastSuccessAt,
    Failure? Function()? lastFailure,
  }) => SyncEngineState(
    running: running ?? this.running,
    lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
    lastFailure: lastFailure == null ? this.lastFailure : lastFailure(),
  );

  @override
  bool operator ==(Object other) =>
      other is SyncEngineState &&
      other.running == running &&
      other.lastSuccessAt == lastSuccessAt &&
      other.lastFailure == lastFailure;

  @override
  int get hashCode => Object.hash(running, lastSuccessAt, lastFailure);
}

/// Pushes the outbox, then pulls the server's changes (contract §4).
///
/// - **Push**: ops in local order, [pushBatch] at a time. Accepted ops
///   (`applied`, `duplicate`, `merged`) leave the outbox and record the
///   server version. A `rejected` op leaves the outbox in the same
///   transaction that records its issue and undoes what needs no server
///   read; anything else is re-read afterwards (a *repair*, retried on
///   later runs until it succeeds). Ops the server did not answer stay
///   queued and never count against the op.
/// - **Pull**: pages from the stored cursor, parents before children; each
///   page and its cursor are saved in one transaction, so a crash never
///   skips or repeats changes. Local entities with ops still queued are
///   not overwritten. A change that cannot be read is reported and
///   skipped, so one bad row never blocks every later change.
/// - A run stops at the first network or server failure; the caller
///   retries later (`SyncScheduler`). Concurrent calls share one run.
/// - A batch refused as a bad request (400, 409, 413, 422) is retried one
///   op at a time; an op refused alone [maxAttempts] times is given up and
///   becomes an issue, so one bad op never blocks the queue and valid ops
///   are never dropped with it. Outages (network, 5xx, 429, 401, 403, 404)
///   never count.
/// - Runs only while [enabled] (a signed-in user's data is ready).
final class SyncEngine {
  SyncEngine({
    required AppDatabase db,
    required SyncRemoteDataSource remote,
    required OutboxStore outbox,
    required SyncCursorStore cursor,
    required SyncIssueStore issues,
    required DeviceIdProvider deviceIds,
    required List<SyncEntityHandler> handlers,
    required IdGenerator ids,
    required Clock clock,
    required AppLogger logger,
    required ErrorReporter reporter,
    this.pushBatch = 100,
    this.pullPage = 500,
    this.maxAttempts = 5,
  }) : _db = db,
       _remote = remote,
       _outbox = outbox,
       _cursor = cursor,
       _issues = issues,
       _deviceIds = deviceIds,
       _handlers = handlers,
       _ids = ids,
       _clock = clock,
       _logger = logger,
       _reporter = reporter;

  /// Statuses that mean "this batch is wrong", as opposed to an outage or
  /// a misconfiguration that would wrongly drain the queue.
  static const refusedStatuses = {400, 409, 413, 422};

  /// Returned when the server answered without processing the ops sent.
  static const notProcessed = Failure.server(code: 'NOT_PROCESSED');

  final AppDatabase _db;
  final SyncRemoteDataSource _remote;
  final OutboxStore _outbox;
  final SyncCursorStore _cursor;
  final SyncIssueStore _issues;
  final DeviceIdProvider _deviceIds;
  final List<SyncEntityHandler> _handlers;
  final IdGenerator _ids;
  final Clock _clock;
  final AppLogger _logger;
  final ErrorReporter _reporter;
  final int pushBatch;
  final int pullPage;
  final int maxAttempts;

  final _states = StreamController<SyncEngineState>.broadcast(sync: true);
  SyncEngineState _state = const SyncEngineState();
  Future<Failure?>? _running;
  bool _again = false;

  /// Local state changed (pulled or repaired) since handlers last ran
  /// [SyncEntityHandler.afterPull].
  bool _changed = false;

  /// Whether runs may start. The session coordinator turns it on once the
  /// user's data is bound and seeded, and off before it is cleared.
  bool enabled = false;

  SyncEngineState get state => _state;

  /// Completes when no run is in progress (sign-out waits on it before
  /// clearing the data a run may be writing).
  Future<void> get idle async {
    await _running;
  }

  /// [state] first, then every change.
  Stream<SyncEngineState> watch() => Stream<SyncEngineState>.multi((c) {
    c.add(_state);
    final subscription = _states.stream.listen(c.add);
    c.onCancel = subscription.cancel;
  });

  /// Pushes and pulls. Returns null on success, else why it stopped. A
  /// call during a run makes that run go once more (picking up changes
  /// made meanwhile) and completes with it. While not [enabled], returns
  /// `Failure.unauthenticated` without doing anything.
  Future<Failure?> sync() {
    final running = _running;
    if (running != null) {
      _again = true;
      return running;
    }
    if (!enabled) return Future.value(const Failure.unauthenticated());
    final run = _runLoop();
    _running = run;
    return run.whenComplete(() => _running = null);
  }

  Future<void> dispose() async {
    await idle;
    await _states.close();
  }

  Future<Failure?> _runLoop() async {
    _setState(_state.copyWith(running: true));
    Failure? failure;
    do {
      _again = false;
      failure = await _runOnce();
    } while (_again && failure == null && enabled);
    _setState(
      failure == null
          ? SyncEngineState(lastSuccessAt: _clock.now())
          : _state.copyWith(running: false, lastFailure: () => failure),
    );
    return failure;
  }

  Future<Failure?> _runOnce() async {
    try {
      final pushed = await _push();
      await _repair();
      await _pull();
      return pushed;
    } on DioException catch (error) {
      final failure = mapDioException(error);
      _logger.info(
        'sync stopped',
        context: {'failure': failure.runtimeType.toString()},
      );
      return failure;
    } on FormatException catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'sync'});
      return const Failure.server(code: 'INVALID_RESPONSE');
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'sync'});
      return Failure.unexpected(cause: error, stackTrace: stackTrace);
    } finally {
      await _afterChanges();
    }
  }

  // Push

  /// Null when everything queued was settled; [notProcessed] when the
  /// server left ops unanswered (they stay queued; the pull still runs).
  Future<Failure?> _push() async {
    final deviceId = await _deviceIds.deviceId();
    while (true) {
      final queued = await _outbox.pending(limit: pushBatch);
      if (queued.isEmpty) return null;
      // After a refused batch, ops go one at a time until the refused one
      // is found: only it is ever given up.
      final ops = queued.first.attempts > 0 ? [queued.first] : queued;
      final List<PushResult> results;
      try {
        results = await _remote.push(deviceId: deviceId, ops: ops);
      } on DioException catch (error) {
        await _onBatchFailure(ops, error);
        rethrow;
      }
      final byId = {for (final result in results) result.opId: result};
      final settled = await _db.transaction(() async {
        final settled = <String>[];
        for (final op in ops) {
          final result = byId[op.opId];
          if (result == null) continue;
          settled.add(op.opId);
          switch (result.status) {
            case PushStatus.applied ||
                PushStatus.duplicate ||
                PushStatus.merged:
              final version = result.version;
              if (version != null) {
                await _handlerForOp(op.type)?.applyVersion(op, version);
              }
            case PushStatus.rejected:
              await _rejectLocally(op, result.code ?? 'REJECTED');
          }
        }
        await _outbox.remove(settled);
        return settled;
      });
      if (settled.isEmpty) {
        _logger.warning(
          'sync push not processed',
          context: {'ops': ops.length},
        );
        return notProcessed;
      }
    }
  }

  /// A whole batch refused as a bad request ([refusedStatuses]): count the
  /// attempt. Everything else is transient and never counts, so valid
  /// changes survive any outage or misconfiguration.
  Future<void> _onBatchFailure(List<SyncOp> ops, DioException error) async {
    final status = error.response?.statusCode;
    if (!refusedStatuses.contains(status)) return;
    await _db.transaction(() async {
      await _outbox.recordFailure(ops.map((o) => o.opId), 'HTTP $status');
      if (ops.length != 1) return;
      final op = ops.single;
      if (op.attempts + 1 < maxAttempts) return;
      await _outbox.remove([op.opId]);
      await _rejectLocally(op, 'SYNC_FAILED');
    });
  }

  /// Inside the push transaction: the handler's local undo, the issue, and
  /// queued ops that can only be refused too. A crash cannot lose one
  /// without the others.
  Future<void> _rejectLocally(SyncOp op, String code) async {
    final handler = _handlerForOp(op.type);
    final rejection = handler == null
        ? const SyncRejection()
        : await handler.onRejected(op, code);
    final drop = rejection.dropQueued;
    var dropped = 0;
    if (drop != null) {
      final queued = await _outbox.pending();
      final ids = [
        for (final other in queued)
          if (other.opId != op.opId && drop(other)) other.opId,
      ];
      await _outbox.remove(ids);
      dropped = ids.length;
    }
    await _issues.add(
      SyncIssueRecord(
        id: _ids.newId(),
        opType: op.type,
        entityId: op.entityId,
        code: code,
        label: rejection.label,
        repairPending: rejection.needsRepair,
        createdAt: _clock.now(),
      ),
    );
    _changed = true;
    _logger.warning(
      'sync op rejected',
      context: {'type': op.type, 'code': code, 'dropped_after': dropped},
    );
  }

  /// Re-reads entities refused ops left out of line with the server, this
  /// run's and earlier ones'. A read that fails stays pending.
  Future<void> _repair() async {
    for (final issue in await _issues.pendingRepairs()) {
      final handler = _handlerForOp(issue.opType);
      if (handler == null) {
        await _issues.repaired(issue.id);
        continue;
      }
      final pending = await _outbox.pendingEntityIds();
      bool done;
      try {
        done = await handler.repair(
          issue.opType,
          issue.entityId,
          pending: pending,
        );
      } on FormatException catch (error, stackTrace) {
        // An unreadable server answer will not get better by retrying.
        await _reporter.report(error, stackTrace, context: {'step': 'repair'});
        done = true;
      } on Object catch (error, stackTrace) {
        // Stays pending, but never stops the pull that follows.
        await _reporter.report(error, stackTrace, context: {'step': 'repair'});
        continue;
      }
      if (!done) continue;
      await _issues.repaired(issue.id);
      _changed = true;
    }
  }

  SyncEntityHandler? _handlerForOp(String opType) {
    for (final handler in _handlers) {
      if (handler.ownsOp(opType)) return handler;
    }
    return null;
  }

  // Pull

  Future<void> _pull() async {
    while (true) {
      final cursor = await _cursor.read();
      final page = await _remote.pull(cursor: cursor, limit: pullPage);
      await _db.transaction(() async {
        final pending = await _outbox.pendingEntityIds();
        for (final change in _parentsFirst(page.changes)) {
          // Entities this app does not keep (tags, insights) are skipped.
          final handler = _handlerForEntity(change.entity);
          if (handler == null) continue;
          try {
            await handler.applyChange(change, pending: pending);
          } on FormatException catch (error, stackTrace) {
            await _reporter.report(
              error,
              stackTrace,
              context: {'step': 'pull', 'entity': change.entity},
            );
          }
        }
        await _cursor.write(page.cursor);
      });
      if (page.changes.isNotEmpty) _changed = true;
      if (!page.hasMore || page.cursor == cursor) break;
    }
  }

  /// Stable: server order within each rank.
  List<SyncChange> _parentsFirst(List<SyncChange> changes) {
    int rank(SyncChange change) =>
        _handlerForEntity(change.entity)?.rankOf(change.entity) ?? 0;
    final indexed = changes.indexed.toList()
      ..sort((a, b) {
        final byRank = rank(a.$2).compareTo(rank(b.$2));
        return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
      });
    return [for (final (_, change) in indexed) change];
  }

  /// Runs once per run after any committed change, even if the run then
  /// failed, so pulled series always get their occurrences.
  Future<void> _afterChanges() async {
    if (!_changed) return;
    _changed = false;
    for (final handler in _handlers) {
      try {
        await handler.afterPull();
      } on Object catch (error, stackTrace) {
        await _reporter.report(
          error,
          stackTrace,
          context: {'step': 'after_pull'},
        );
      }
    }
  }

  SyncEntityHandler? _handlerForEntity(String entity) {
    for (final handler in _handlers) {
      if (handler.entities.contains(entity)) return handler;
    }
    return null;
  }

  void _setState(SyncEngineState state) {
    if (state == _state) return;
    _state = state;
    if (!_states.isClosed) _states.add(state);
  }
}
