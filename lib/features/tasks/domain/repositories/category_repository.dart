import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';

abstract interface class CategoryRepository {
  /// Active categories by sort order.
  Stream<Result<List<Category>>> watchCategories();

  Future<Result<Category>> createCategory({
    required String name,
    required CategoryColor color,
  });

  /// Inserts the default categories for [userId] if they are missing. Ids
  /// are deterministic (contract §4.2), so this is safe on every sign-in
  /// and on every device, and the server seeds the same rows.
  Future<Result<Unit>> ensureDefaultCategories(String userId);
}
