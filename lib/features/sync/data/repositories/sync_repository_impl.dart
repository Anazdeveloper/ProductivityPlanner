import 'dart:async';

import 'package:productivity_planner/core/database/local_guard.dart';
import 'package:productivity_planner/core/device/connectivity_monitor.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';
import 'package:productivity_planner/core/sync/sync_stores.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/sync/domain/repositories/sync_repository.dart';

/// The sync feature over the core engine: status joins the engine's state,
/// the outbox size and connectivity.
final class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required SyncEngine engine,
    required OutboxWriter outbox,
    required SyncIssueStore issues,
    required ConnectivityMonitor connectivity,
    required ErrorReporter reporter,
  }) : _engine = engine,
       _outbox = outbox,
       _issues = issues,
       _connectivity = connectivity,
       _reporter = reporter;

  final SyncEngine _engine;
  final OutboxWriter _outbox;
  final SyncIssueStore _issues;
  final ConnectivityMonitor _connectivity;
  final ErrorReporter _reporter;

  @override
  Stream<SyncStatus> watchStatus() => Stream<SyncStatus>.multi((controller) {
    var engine = _engine.state;
    int? pending;
    var online = true;
    SyncStatus? last;

    void publish() {
      final count = pending;
      // The count arrives first from the database; until then nothing
      // honest can be said about pending changes.
      if (count == null) return;
      final status = SyncStatus(
        pendingChanges: count,
        syncing: engine.running,
        online: online,
        lastSyncedAt: engine.lastSuccessAt,
        lastFailure: engine.lastFailure,
      );
      if (status == last) return;
      last = status;
      controller.add(status);
    }

    final subscriptions = <StreamSubscription<Object?>>[
      _engine.watch().listen((value) {
        engine = value;
        publish();
      }),
      _outbox.watchPendingCount().listen(
        (value) {
          pending = value;
          publish();
        },
        onError: (Object error, StackTrace stackTrace) => unawaited(
          _reporter.report(
            error,
            stackTrace,
            context: {'operation': 'watchPendingCount'},
          ),
        ),
      ),
      _connectivity.watchOnline().listen((value) {
        online = value;
        publish();
      }),
    ];
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  });

  @override
  Future<Result<Unit>> syncNow() async {
    final failure = await _engine.sync();
    return failure == null ? const Ok(unit) : Err(failure);
  }

  @override
  Stream<Result<List<SyncIssue>>> watchIssues() => guardLocalStream(
    _reporter,
    'watchSyncIssues',
    _issues.watch().map((records) => records.map(_toIssue).toList()),
  );

  @override
  Future<Result<Unit>> dismissIssue(String id) =>
      guardLocal(_reporter, 'dismissSyncIssue', () async {
        await _issues.dismiss(id);
        return const Ok(unit);
      });

  @override
  Future<Result<Unit>> dismissAllIssues() =>
      guardLocal(_reporter, 'dismissAllSyncIssues', () async {
        await _issues.dismissAll();
        return const Ok(unit);
      });

  static SyncIssue _toIssue(SyncIssueRecord record) => SyncIssue(
    id: record.id,
    subject: switch (record.opType.split('.').first) {
      'series' => SyncIssueSubject.task,
      'occurrence' => SyncIssueSubject.occurrence,
      'category' => SyncIssueSubject.category,
      _ => SyncIssueSubject.other,
    },
    reason: SyncIssueReason.fromCode(record.code),
    code: record.code,
    label: record.label,
    createdAt: record.createdAt,
  );
}
