import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/sync/sync_stores.dart';
import 'package:productivity_planner/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';

import '../../helpers/fake_sync.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_database.dart';

void main() {
  late TasksTestHarness h;
  late SyncTestRig rig;
  late FakeConnectivity connectivity;
  late SyncRepositoryImpl repository;

  setUp(() {
    h = TasksTestHarness(clock: FixedClock(DateTime.utc(2026, 10, 7, 7)));
    rig = SyncTestRig(h);
    connectivity = FakeConnectivity();
    repository = SyncRepositoryImpl(
      engine: rig.engine,
      outbox: h.outbox,
      issues: rig.issueStore,
      connectivity: connectivity,
      reporter: h.reporter,
    );
  });

  tearDown(() => h.dispose());

  test('status joins pending changes, connectivity and the last run', () async {
    final statuses = <SyncStatus>[];
    final subscription = repository.watchStatus().listen(statuses.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();
    expect(statuses.last, const SyncStatus());

    await h.categories.createCategory(
      name: 'Garden',
      color: CategoryColor.green,
    );
    connectivity.online = false;
    await pumpEventQueue();
    expect(statuses.last.pendingChanges, 1);
    expect(statuses.last.online, isFalse);

    connectivity.online = true;
    expect(await repository.syncNow(), isA<Ok<Unit>>());
    await pumpEventQueue();
    expect(statuses.last.pendingChanges, 0);
    expect(statuses.last.upToDate, isTrue);
    expect(statuses.any((s) => s.syncing), isTrue);
  });

  test('syncNow reports why a run stopped', () async {
    rig.server.pullError = networkError();
    final result = await repository.syncNow();
    expect(
      result,
      isA<Err<Unit>>().having(
        (e) => e.failure,
        'failure',
        const Failure.network(),
      ),
    );
  });

  test('issues map op types and codes; dismissing removes them', () async {
    Future<void> add(String id, String type, String code) =>
        rig.issueStore.add(
          SyncIssueRecord(
            id: id,
            opType: type,
            entityId: 'e-$id',
            code: code,
            label: id == 'a' ? 'Run' : null,
            createdAt: DateTime.utc(2026, 10, 7, id == 'a' ? 8 : 9),
          ),
        );
    await add('a', 'series.update', 'ENTITY_DELETED');
    await add('b', 'occurrence.complete', 'ALREADY_RESOLVED');

    final issues = switch (await repository.watchIssues().first) {
      Ok(:final value) => value,
      Err(:final failure) => throw TestFailure('$failure'),
    };
    // Newest first.
    expect(issues.map((i) => i.id), ['b', 'a']);
    expect(issues.first.subject, SyncIssueSubject.occurrence);
    expect(issues.first.reason, SyncIssueReason.conflict);
    expect(issues.last.subject, SyncIssueSubject.task);
    expect(issues.last.reason, SyncIssueReason.deleted);
    expect(issues.last.label, 'Run');

    await repository.dismissIssue('b');
    expect(await rig.issues(), hasLength(1));
    await repository.dismissAllIssues();
    expect(await rig.issues(), isEmpty);
  });

  test('codes map to reasons the person can act on', () {
    expect(SyncIssueReason.fromCode('NOT_FOUND'), SyncIssueReason.deleted);
    expect(SyncIssueReason.fromCode('STALE_VERSION'), SyncIssueReason.conflict);
    expect(SyncIssueReason.fromCode('LIMIT_REACHED'), SyncIssueReason.plan);
    expect(
      SyncIssueReason.fromCode('VALIDATION_FAILED'),
      SyncIssueReason.invalid,
    );
    expect(SyncIssueReason.fromCode('SYNC_FAILED'), SyncIssueReason.failed);
    expect(SyncIssueReason.fromCode('SOMETHING_NEW'), SyncIssueReason.other);
  });
}
