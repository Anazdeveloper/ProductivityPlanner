import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/router/app_routes.dart';
import 'package:productivity_planner/core/time/local_date.dart';

void main() {
  test('newTask adds only the given prefills', () {
    expect(AppRoutes.newTask(), '/tasks/new');
    expect(
      AppRoutes.newTask(date: LocalDate(2026, 10, 9), title: 'Read & think'),
      '/tasks/new?date=2026-10-09&title=Read+%26+think',
    );
    expect(AppRoutes.newTask(title: ''), '/tasks/new');
  });

  test('editTask encodes the id and the start date', () {
    expect(AppRoutes.editTask('abc'), '/tasks/abc/edit');
    expect(
      AppRoutes.editTask('abc', from: LocalDate(2026, 10, 9)),
      '/tasks/abc/edit?from=2026-10-09',
    );
  });
}
