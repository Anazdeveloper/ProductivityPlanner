import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/data/datasources/category_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/repositories/category_repository_impl.dart';
import 'package:productivity_planner/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';
import 'package:productivity_planner/features/tasks/domain/services/recurrence_expander.dart';

import 'fakes.dart';

/// A fresh in-memory database. SQLite is bundled by `sqlite3` 3.x build
/// hooks, so no system library is needed.
AppDatabase testDatabase() {
  // Several databases are created per test file; each is closed in
  // tearDown, so drift's "multiple databases" warning is noise here.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Real repositories on an in-memory database: the tasks data layer exactly
/// as the app wires it, minus the service locator.
final class TasksTestHarness {
  TasksTestHarness({required this.clock, AppDatabase? db})
    : db = db ?? testDatabase() {
    meta = AppMetaStore(this.db);
    outbox = OutboxWriter(db: this.db, ids: ids, clock: clock);
    taskLocal = TaskLocalDataSource(this.db);
    categoryLocal = CategoryLocalDataSource(this.db);
    tasks = TaskRepositoryImpl(
      local: taskLocal,
      outbox: outbox,
      planner: OccurrencePlanner(
        expander: const RecurrenceExpander(),
        converter: converter,
      ),
      lifecycle: OccurrenceLifecycle(ids: ids, converter: converter),
      converter: converter,
      ids: ids,
      clock: clock,
      reporter: reporter,
    );
    categories = CategoryRepositoryImpl(
      local: categoryLocal,
      outbox: outbox,
      ids: ids,
      clock: clock,
      reporter: reporter,
    );
  }

  final AppDatabase db;
  final Clock clock;
  final IdGenerator ids = const UuidV7IdGenerator();
  final TimeZoneConverter converter = TzTimeZoneConverter();
  final RecordingErrorReporter reporter = RecordingErrorReporter();
  late final AppMetaStore meta;
  late final OutboxWriter outbox;
  late final TaskLocalDataSource taskLocal;
  late final CategoryLocalDataSource categoryLocal;
  late final TaskRepositoryImpl tasks;
  late final CategoryRepositoryImpl categories;

  Future<List<OutboxOperationRow>> outboxRows() => (db.select(
    db.outboxOperations,
  )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();

  Future<void> dispose() => db.close();
}
