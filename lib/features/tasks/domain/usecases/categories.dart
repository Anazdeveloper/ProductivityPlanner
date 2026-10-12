import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/category_repository.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

final class WatchCategories implements StreamUseCase<List<Category>, NoParams> {
  const WatchCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Stream<Result<List<Category>>> call(NoParams params) =>
      _repository.watchCategories();
}

final class CreateCategoryParams {
  const CreateCategoryParams({required this.name, required this.color});

  final String name;
  final CategoryColor color;
}

final class CreateCategory implements UseCase<Category, CreateCategoryParams> {
  const CreateCategory({
    required CategoryRepository repository,
    required TaskRules rules,
  }) : _repository = repository,
       _rules = rules;

  final CategoryRepository _repository;
  final TaskRules _rules;

  @override
  Future<Result<Category>> call(CreateCategoryParams params) async {
    final valid = _rules.validateCategoryName(params.name);
    if (valid case Err(:final failure)) return Err(failure);
    return await _repository.createCategory(
      name: params.name.trim(),
      color: params.color,
    );
  }
}

/// Seeds Work, Study, Health, Personal and Home for the signed-in user.
final class EnsureDefaultCategories implements UseCase<Unit, String> {
  const EnsureDefaultCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<Unit>> call(String userId) =>
      _repository.ensureDefaultCategories(userId);
}
