import 'package:drift/drift.dart';
import 'package:productivity_planner/core/database/tables.dart';

part 'app_database.g.dart';

/// The app's single local database: the source of truth the UI reads from
/// (offline-first). Feature data sources query it; nothing above `data/`
/// imports it.
///
/// Construct with `openAppDatabase()` in the app and `NativeDatabase.memory()`
/// in tests.
@DriftDatabase(
  tables: [
    AppMeta,
    Categories,
    TaskSeries,
    TaskOccurrences,
    WorkSessions,
    OccurrenceEvents,
    OutboxOperations,
    SyncIssues,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  bool _createdOnOpen = false;

  /// Bump with every schema change and add a step in [migration].
  /// Snapshot each version with `dart run drift_dev make-migrations`.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Partial index: drift's annotations cannot express WHERE.
      await customStatement(
        'CREATE UNIQUE INDEX work_sessions_one_open_per_occurrence '
        'ON work_sessions (occurrence_id) WHERE ended_at IS NULL',
      );
    },
    onUpgrade: (m, from, to) async {
      // v2 (Phase 11): rejected sync changes.
      if (from < 2) await m.createTable(syncIssues);
    },
    beforeOpen: (details) async {
      _createdOnOpen = details.wasCreated;
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Whether this launch created the database file, i.e. a fresh install
  /// (or the user cleared app data). Opens the database if needed.
  ///
  /// Used to discard Keychain items that survive an iOS uninstall.
  Future<bool> createdOnThisLaunch() async {
    await customSelect('SELECT 1').get();
    return _createdOnOpen;
  }
}
