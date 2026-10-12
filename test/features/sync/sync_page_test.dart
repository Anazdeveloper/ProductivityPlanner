import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:productivity_planner/features/sync/presentation/pages/sync_page.dart';
import 'package:productivity_planner/features/sync/presentation/widgets/sync_settings_tile.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../helpers/fake_sync.dart';

SyncIssue _issue(String id, SyncIssueReason reason, {String? label}) =>
    SyncIssue(
      id: id,
      subject: SyncIssueSubject.task,
      reason: reason,
      code: 'CODE_$id',
      label: label,
      createdAt: DateTime.utc(2026, 10, 7),
    );

void main() {
  late FakeSyncRepository repository;

  setUp(() => repository = FakeSyncRepository());

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) => buildSyncStatusCubit(repository)..start(),
          child: child,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SyncStatusCubit', () {
    late SyncStatusCubit cubit;

    setUp(() => cubit = buildSyncStatusCubit(repository)..start());

    tearDown(() => cubit.close());

    test('follows status and issues', () async {
      await pumpEventQueue();
      expect(cubit.state.status, const SyncStatus());

      repository
        ..status = const SyncStatus(pendingChanges: 2)
        ..issues = [_issue('a', SyncIssueReason.deleted)];
      await pumpEventQueue();

      expect(cubit.state.status?.pendingChanges, 2);
      expect(cubit.state.issues.single.id, 'a');
    });

    test('a manual sync ignores repeats and reports its outcome', () async {
      final gate = Completer<void>();
      repository.syncGate = gate;

      final first = cubit.syncNow();
      expect(cubit.state.syncing, isTrue);
      unawaited(cubit.syncNow());
      gate.complete();
      await first;

      expect(repository.syncCalls, 1);
      expect(cubit.state.syncedCount, 1);

      repository
        ..syncGate = null
        ..syncResult = const Err(Failure.network());
      await cubit.syncNow();
      expect(cubit.state.failureCount, 1);
      expect(cubit.state.failure, const Failure.network());
    });
  });

  group('SyncSettingsTile', () {
    testWidgets('shows pending changes and offline state', (tester) async {
      repository.status = const SyncStatus(pendingChanges: 3, online: false);
      await pump(tester, Scaffold(body: SyncSettingsTile(onTap: () {})));

      expect(find.text('3 changes waiting to sync'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    });

    testWidgets('flags refused changes', (tester) async {
      repository.issues = [_issue('a', SyncIssueReason.conflict)];
      await pump(tester, Scaffold(body: SyncSettingsTile(onTap: () {})));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('SyncPage', () {
    testWidgets('up to date: status, last sync and the button', (
      tester,
    ) async {
      repository.status = SyncStatus(
        lastSyncedAt: DateTime.utc(2026, 10, 7, 14, 5),
      );
      await pump(tester, const SyncPage());

      expect(find.text('All changes synced'), findsOneWidget);
      expect(find.textContaining('Last synced'), findsOneWidget);
      await tester.tap(find.byKey(SyncPage.syncNowKey));
      await tester.pumpAndSettle();
      expect(repository.syncCalls, 1);
      expect(find.text('Everything is up to date'), findsOneWidget);
      // Let the snackbar's timer run out so none outlives the test.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('offline explains that work is kept', (tester) async {
      repository.status = const SyncStatus(online: false);
      await pump(tester, const SyncPage());
      expect(
        find.text('Offline. Changes are saved on this device.'),
        findsOneWidget,
      );
      expect(find.textContaining("You're offline"), findsOneWidget);
    });

    testWidgets('a failed run shows why', (tester) async {
      repository.status = const SyncStatus(
        lastFailure: Failure.server(statusCode: 503),
      );
      await pump(tester, const SyncPage());
      expect(find.text("Last sync didn't finish"), findsOneWidget);
    });

    testWidgets('lists refused changes and dismisses them', (tester) async {
      repository.issues = [
        _issue('a', SyncIssueReason.deleted, label: 'Run'),
        _issue('b', SyncIssueReason.plan),
      ];
      await pump(tester, const SyncPage());

      expect(find.text("Changes that couldn't sync"), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('A task'), findsOneWidget);
      expect(find.textContaining('Deleted on another device'), findsOneWidget);
      expect(find.textContaining('current plan'), findsOneWidget);

      await tester.tap(find.byTooltip('Dismiss').first);
      await tester.pumpAndSettle();
      expect(repository.dismissed, ['a']);
      expect(find.text('Run'), findsNothing);

      repository.issues = [
        _issue('c', SyncIssueReason.other),
        _issue('d', SyncIssueReason.failed),
      ];
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(SyncPage.dismissAllKey));
      await tester.pumpAndSettle();
      expect(find.text("Changes that couldn't sync"), findsNothing);
    });
  });
}
