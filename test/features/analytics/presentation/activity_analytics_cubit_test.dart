import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/activity_analytics_cubit.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_feature_access.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

/// Six runs planned for 30 minutes that each took 45.
List<AgendaItem> _runs() => [
  for (var day = 1; day <= 6; day++)
    agendaItem(
      id: 'run-$day',
      date: LocalDate(2026, 10, day),
      lineageId: 'run',
      title: 'Run',
      status: OccurrenceStatus.completed,
      actual: const Duration(minutes: 45),
    ),
];

void main() {
  late FakeTaskRepository tasks;
  late TaskCubitFactory factory;

  setUp(() {
    tasks = FakeTaskRepository(_runs());
    factory = TaskCubitFactory(
      tasks: tasks,
      clock: FixedClock(DateTime.utc(2026, 10, 7, 6, 30)),
    );
  });

  Future<void> settle() => pumpEventQueue();

  test('streaks, history and a duration suggestion', () async {
    final cubit = factory.activity(
      'run',
      access: const FakeFeatureAccess(advancedAnalytics: true),
    );
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    final stats = cubit.state.stats;
    expect(cubit.state.load, ActivityLoad.ready);
    expect(stats?.title, 'Run');
    expect(stats?.currentStreak, 6);
    expect(stats?.history, hasLength(6));
    expect(cubit.state.from, LocalDate(2026, 7, 10), reason: '90 days');
    expect(cubit.state.suggestion?.suggested, const Duration(minutes: 45));
    expect(cubit.state.suggestionLocked, isFalse);
  });

  test('applying the suggestion updates the current task', () async {
    final cubit = factory.activity(
      'run',
      access: const FakeFeatureAccess(advancedAnalytics: true),
    );
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    await cubit.applySuggestion();

    final (taskId, details) = tasks.detailUpdates.single;
    expect(taskId, 'task-run-6');
    expect(details.plannedDuration, const Duration(minutes: 45));
    expect(details.title, 'Run');
    expect(cubit.state.appliedCount, 1);
    expect(cubit.state.applying, isFalse);
  });

  test('without advanced analytics the suggestion is locked', () async {
    final cubit = factory.activity(
      'run',
      access: const FakeFeatureAccess(historyDays: 30),
    );
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    expect(cubit.state.suggestion, isNull);
    expect(cubit.state.suggestionLocked, isTrue);
    expect(cubit.state.from, LocalDate(2026, 9, 8), reason: 'plan window');

    await cubit.applySuggestion();
    expect(tasks.detailUpdates, isEmpty);
  });

  test('an unknown activity is reported as not found', () async {
    final cubit = factory.activity('nope');
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    expect(cubit.state.load, ActivityLoad.notFound);
  });
}
