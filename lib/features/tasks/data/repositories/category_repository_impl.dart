import 'package:productivity_planner/core/database/local_guard.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/tasks/data/datasources/category_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/models/sync_payload_dtos.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/category_repository.dart';

/// The categories every account starts with (contract §4.2). The key is
/// part of the deterministic id, so it must never change.
const defaultCategorySeeds = <({String key, String name, CategoryColor color})>[
  (key: 'work', name: 'Work', color: CategoryColor.blue),
  (key: 'study', name: 'Study', color: CategoryColor.purple),
  (key: 'health', name: 'Health', color: CategoryColor.green),
  (key: 'personal', name: 'Personal', color: CategoryColor.orange),
  (key: 'home', name: 'Home', color: CategoryColor.teal),
];

/// `UUIDv5(user_id, "category:<key>")`.
String defaultCategoryId(String userId, String key) =>
    deterministicId(namespace: userId, name: 'category:$key');

final class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required CategoryLocalDataSource local,
    required OutboxWriter outbox,
    required IdGenerator ids,
    required Clock clock,
    required ErrorReporter reporter,
  }) : _local = local,
       _outbox = outbox,
       _ids = ids,
       _clock = clock,
       _reporter = reporter;

  final CategoryLocalDataSource _local;
  final OutboxWriter _outbox;
  final IdGenerator _ids;
  final Clock _clock;
  final ErrorReporter _reporter;

  @override
  Stream<Result<List<Category>>> watchCategories() =>
      guardLocalStream(_reporter, 'watchCategories', _local.watchActive());

  @override
  Future<Result<Category>> createCategory({
    required String name,
    required CategoryColor color,
  }) => guardLocal(
    _reporter,
    'createCategory',
    () => _local.transaction(() async {
      final now = _clock.now();
      final category = Category(
        id: _ids.newId(),
        name: name,
        color: color,
        sortOrder: await _local.nextSortOrder(),
      );
      await _local.insert(category, now: now);
      await _outbox.enqueue(
        type: SyncOpType.categoryCreate,
        entityId: category.id,
        payload: CategoryDto.fromCategory(category).toJson(),
        occurredAt: now,
      );
      return Ok(category);
    }),
  );

  /// No outbox ops: the server seeds the same rows (same ids) at sign-up.
  @override
  Future<Result<Unit>> ensureDefaultCategories(String userId) => guardLocal(
    _reporter,
    'ensureDefaultCategories',
    () => _local.transaction(() async {
      final now = _clock.now();
      final defaults = [
        for (final (index, seed) in defaultCategorySeeds.indexed)
          Category(
            id: defaultCategoryId(userId, seed.key),
            name: seed.name,
            color: seed.color,
            sortOrder: index,
            isDefault: true,
          ),
      ];
      final existing = await _local.existingIds(defaults.map((c) => c.id));
      for (final category in defaults) {
        if (!existing.contains(category.id)) {
          await _local.insert(category, now: now);
        }
      }
      return const Ok(unit);
    }),
  );
}
