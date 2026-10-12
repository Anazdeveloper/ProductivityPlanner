import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';

/// v1 → v2 by hand until `drift_dev make-migrations` snapshots exist
/// (docs/ARCHITECTURE.md §12f): a v2 file is turned back into v1 (no
/// `sync_issues`, `user_version = 1`) and reopened.
void main() {
  late Directory dir;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    dir = Directory.systemTemp.createTempSync('migration_test');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('v1 → v2 adds sync_issues and keeps existing data', () async {
    final file = File('${dir.path}/app.sqlite');

    final v2 = AppDatabase(NativeDatabase(file));
    await AppMetaStore(v2).write(AppMetaKeys.boundUserId, 'user-1');
    await v2.customStatement('DROP TABLE sync_issues');
    await v2.customStatement('PRAGMA user_version = 1');
    await v2.close();

    final upgraded = AppDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    expect(
      await AppMetaStore(upgraded).read(AppMetaKeys.boundUserId),
      'user-1',
    );
    await upgraded
        .into(upgraded.syncIssues)
        .insert(
          SyncIssuesCompanion.insert(
            id: 'i1',
            opType: 'series.update',
            entityId: 's1',
            code: 'ENTITY_DELETED',
            createdAt: DateTime.utc(2026, 10, 8),
          ),
        );
    expect(await upgraded.select(upgraded.syncIssues).get(), hasLength(1));
    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 2);
  });
}
