import 'package:drift/drift.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/features/tasks/data/models/task_mappers.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';

final class CategoryLocalDataSource {
  const CategoryLocalDataSource(this._db);

  final AppDatabase _db;

  Future<T> transaction<T>(Future<T> Function() action) =>
      _db.transaction(action);

  Stream<List<Category>> watchActive() =>
      (_db.select(_db.categories)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.name),
            ]))
          .watch()
          .map((rows) => rows.map(categoryFromRow).toList());

  /// Ids among [ids] that exist, including soft-deleted ones (a default the
  /// user deleted must not come back).
  Future<Set<String>> existingIds(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return const {};
    final rows = await (_db.selectOnly(_db.categories)
          ..addColumns([_db.categories.id])
          ..where(_db.categories.id.isIn(list)))
        .map((row) => row.read(_db.categories.id))
        .get();
    return rows.whereType<String>().toSet();
  }

  Future<int> nextSortOrder() async {
    final max = _db.categories.sortOrder.max();
    final row = await (_db.selectOnly(
      _db.categories,
    )..addColumns([max])).getSingle();
    return (row.read(max) ?? -1) + 1;
  }

  // Sync (Phase 11)

  Future<Category?> getCategory(String id) async {
    final row = await (_db.select(
      _db.categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : categoryFromRow(row);
  }

  /// Inserts, or updates every column except `created_at` and
  /// `deleted_at`.
  Future<void> upsert(Category category, {required DateTime now}) {
    final row = categoryToCompanion(category, now: now);
    return _db
        .into(_db.categories)
        .insert(
          row,
          onConflict: DoUpdate(
            (_) => row.copyWith(createdAt: const Value.absent()),
          ),
        );
  }

  Future<void> markDeleted(String id, DateTime now) =>
      (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );

  Future<void> deleteRow(String id) =>
      (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();

  Future<void> setVersion(String id, int version) =>
      (_db.update(_db.categories)..where(
            (t) => t.id.equals(id) & t.version.isSmallerThanValue(version),
          ))
          .write(CategoriesCompanion(version: Value(version)));

  Future<void> insert(Category category, {required DateTime now}) => _db
      .into(_db.categories)
      .insert(
        categoryToCompanion(category, now: now),
        mode: InsertMode.insertOrIgnore,
      );
}
