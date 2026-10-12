import 'dart:async';

import 'package:dio/dio.dart';
import 'package:productivity_planner/core/device/connectivity_monitor.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';
import 'package:productivity_planner/core/sync/sync_remote_data_source.dart';
import 'package:productivity_planner/core/sync/sync_stores.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/sync/domain/repositories/sync_repository.dart';
import 'package:productivity_planner/features/sync/domain/usecases/sync_usecases.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_sync_remote_data_source.dart';
import 'package:productivity_planner/features/tasks/data/sync/task_sync_handler.dart';

import 'fakes.dart';
import 'test_database.dart';

DioException networkError() => DioException(
  requestOptions: RequestOptions(path: 'sync/push'),
  type: DioExceptionType.connectionError,
);

DioException httpError(
  int status, {
  String path = 'sync/push',
  String? code,
}) {
  final request = RequestOptions(path: path);
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response<Object?>(
      requestOptions: request,
      statusCode: status,
      data: code == null
          ? null
          : {
              'type': 'about:blank',
              'title': code,
              'status': status,
              'code': code,
            },
    ),
  );
}

/// A scriptable server. Pushes are applied by default (version 1, 2, … per
/// entity); [onPush] overrides; [pushError] / [pullError] throw.
final class FakeSyncServer implements SyncRemoteDataSource {
  final List<List<SyncOp>> pushed = [];
  final List<int> pullCursors = [];
  final List<PullPage> pages = [];
  List<PushResult> Function(List<SyncOp> ops)? onPush;
  DioException? pushError;
  DioException? pullError;

  /// Completes each push only when completed (to test overlapping runs).
  Completer<void>? pushGate;

  final Map<String, int> _versions = {};

  @override
  Future<List<PushResult>> push({
    required String deviceId,
    required List<SyncOp> ops,
  }) async {
    pushed.add(ops);
    await pushGate?.future;
    final error = pushError;
    if (error != null) throw error;
    final custom = onPush;
    if (custom != null) return custom(ops);
    return [for (final op in ops) applied(op)];
  }

  PushResult applied(SyncOp op) {
    final version = (_versions[op.entityId] ?? 0) + 1;
    _versions[op.entityId] = version;
    return PushResult(
      opId: op.opId,
      status: PushStatus.applied,
      version: version,
    );
  }

  @override
  Future<PullPage> pull({required int cursor, required int limit}) async {
    pullCursors.add(cursor);
    final error = pullError;
    if (error != null) throw error;
    if (pages.isEmpty) {
      return PullPage(changes: const [], cursor: cursor, hasMore: false);
    }
    return pages.removeAt(0);
  }
}

/// REST reads used when a rejected op is repaired. A missing id is the
/// server's `404 NOT_FOUND`; [unrouted] makes it a bare 404 instead.
final class FakeTaskSyncRemote implements TaskSyncRemoteDataSource {
  final Map<String, Map<String, Object?>> series = {};
  final Map<String, Map<String, Object?>> occurrences = {};
  List<Map<String, Object?>> categories = [];
  bool offline = false;
  bool unrouted = false;
  int reads = 0;

  Future<Map<String, Object?>> _read(
    Map<String, Map<String, Object?>> source,
    String id,
  ) async {
    reads++;
    if (offline) throw networkError();
    final found = source[id];
    if (found == null) {
      throw httpError(404, path: id, code: unrouted ? null : 'NOT_FOUND');
    }
    return found;
  }

  @override
  Future<Map<String, Object?>> getSeries(String id) => _read(series, id);

  @override
  Future<Map<String, Object?>> getOccurrence(String id) =>
      _read(occurrences, id);

  @override
  Future<List<Map<String, Object?>>> getCategories() async {
    if (offline) throw networkError();
    return categories;
  }
}

/// The real engine and task handler on a [TasksTestHarness] database.
final class SyncTestRig {
  SyncTestRig(this.h, {int maxAttempts = 5, int pushBatch = 100}) {
    outboxStore = OutboxStore(h.db);
    issueStore = SyncIssueStore(h.db);
    cursor = SyncCursorStore(h.meta);
    handler = TaskSyncHandler(
      tasks: h.taskLocal,
      categories: h.categoryLocal,
      remote: rest,
      repository: h.tasks,
      converter: h.converter,
      clock: h.clock,
    );
    engine = SyncEngine(
      db: h.db,
      remote: server,
      outbox: outboxStore,
      cursor: cursor,
      issues: issueStore,
      deviceIds: const FixedDeviceIdProvider(),
      handlers: [handler],
      ids: SequentialIdGenerator(),
      clock: h.clock,
      logger: logger,
      reporter: h.reporter,
      maxAttempts: maxAttempts,
      pushBatch: pushBatch,
    )..enabled = true;
  }

  final TasksTestHarness h;
  final FakeSyncServer server = FakeSyncServer();
  final FakeTaskSyncRemote rest = FakeTaskSyncRemote();
  final RecordingLogger logger = RecordingLogger();
  late final OutboxStore outboxStore;
  late final SyncIssueStore issueStore;
  late final SyncCursorStore cursor;
  late final TaskSyncHandler handler;
  late final SyncEngine engine;

  Future<List<SyncIssueRecord>> issues() => issueStore.watch().first;
}

final class FakeConnectivity implements ConnectivityMonitor {
  FakeConnectivity({bool online = true}) : _online = online;

  bool _online;
  final _changes = StreamController<bool>.broadcast(sync: true);

  bool get online => _online;

  set online(bool value) {
    if (value == _online) return;
    _online = value;
    _changes.add(value);
  }

  @override
  Future<bool> isOnline() async => _online;

  @override
  Stream<bool> watchOnline() => Stream<bool>.multi((c) {
    c.add(_online);
    final subscription = _changes.stream.listen(c.add);
    c.onCancel = subscription.cancel;
  });
}

/// For the sync UI.
final class FakeSyncRepository implements SyncRepository {
  FakeSyncRepository({SyncStatus status = const SyncStatus()})
    : _status = status;

  SyncStatus _status;
  List<SyncIssue> _issues = [];
  final _statuses = StreamController<SyncStatus>.broadcast(sync: true);
  final _issueChanges = StreamController<List<SyncIssue>>.broadcast(
    sync: true,
  );
  Result<Unit> syncResult = const Ok(unit);
  Completer<void>? syncGate;
  int syncCalls = 0;
  final List<String> dismissed = [];

  SyncStatus get status => _status;

  set status(SyncStatus value) {
    _status = value;
    _statuses.add(value);
  }

  List<SyncIssue> get issues => _issues;

  set issues(List<SyncIssue> value) {
    _issues = value;
    _issueChanges.add(value);
  }

  @override
  Stream<SyncStatus> watchStatus() => Stream<SyncStatus>.multi((c) {
    c.add(_status);
    final subscription = _statuses.stream.listen(c.add);
    c.onCancel = subscription.cancel;
  });

  @override
  Stream<Result<List<SyncIssue>>> watchIssues() =>
      Stream<Result<List<SyncIssue>>>.multi((c) {
        c.add(Ok(_issues));
        final subscription = _issueChanges.stream.listen(
          (value) => c.add(Ok(value)),
        );
        c.onCancel = subscription.cancel;
      });

  @override
  Future<Result<Unit>> syncNow() async {
    syncCalls++;
    await syncGate?.future;
    return syncResult;
  }

  @override
  Future<Result<Unit>> dismissIssue(String id) async {
    dismissed.add(id);
    issues = _issues.where((i) => i.id != id).toList();
    return const Ok(unit);
  }

  @override
  Future<Result<Unit>> dismissAllIssues() async {
    dismissed.addAll(_issues.map((i) => i.id));
    issues = const [];
    return const Ok(unit);
  }
}

SyncStatusCubit buildSyncStatusCubit(SyncRepository repository) =>
    SyncStatusCubit(
      watchStatus: WatchSyncStatus(repository),
      watchIssues: WatchSyncIssues(repository),
      syncNow: SyncNow(repository),
      dismissIssue: DismissSyncIssue(repository),
      dismissAll: DismissAllSyncIssues(repository),
    );

const offlineFailure = Failure.network();
