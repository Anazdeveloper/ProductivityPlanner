import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/tasks/data/repositories/category_repository_impl.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_database.dart';

const _userId = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2a40';

void main() {
  late TasksTestHarness h;

  setUp(() => h = TasksTestHarness(clock: FixedClock(DateTime.utc(2026, 10, 7))));
  tearDown(() => h.dispose());

  Future<List<Category>> categories() async =>
      (await h.categories.watchCategories().first).valueOrNull ?? const [];

  test('seeds the defaults once, with deterministic ids, and no ops', () async {
    expect((await h.categories.ensureDefaultCategories(_userId)).isOk, isTrue);
    expect((await h.categories.ensureDefaultCategories(_userId)).isOk, isTrue);

    final seeded = await categories();
    expect(seeded.map((c) => c.name), [
      'Work',
      'Study',
      'Health',
      'Personal',
      'Home',
    ]);
    expect(seeded.first.id, defaultCategoryId(_userId, 'work'));
    expect(seeded.every((c) => c.isDefault), isTrue);
    expect(await h.outboxRows(), isEmpty);
  });

  test('default ids are the same for the same user on any device', () {
    expect(
      defaultCategoryId(_userId, 'work'),
      defaultCategoryId(_userId, 'work'),
    );
    expect(
      defaultCategoryId(_userId, 'work'),
      isNot(defaultCategoryId(_userId, 'home')),
    );
  });

  test('a created category goes last and is queued for sync', () async {
    await h.categories.ensureDefaultCategories(_userId);
    final created = switch (await h.categories.createCategory(
      name: 'Errands',
      color: CategoryColor.pink,
    )) {
      Ok(:final value) => value,
      Err(:final failure) => throw TestFailure('$failure'),
    };

    expect(created.sortOrder, 5);
    expect((await categories()).last.name, 'Errands');
    final op = (await h.outboxRows()).single;
    expect(op.type, 'category.create');
    expect(jsonDecode(op.payload), {
      'id': created.id,
      'name': 'Errands',
      'color_key': 'pink',
      'sort_order': 5,
    });
  });
}
