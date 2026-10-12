import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_detail_cubit.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  final today = LocalDate(2026, 10, 7);
  late FixedClock clock;
  late FakeTaskRepository tasks;
  late TaskCubitFactory factory;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 4, 30)); // 10:00 IST
    tasks = FakeTaskRepository([
      agendaItem(
        id: 'occ',
        date: today,
        title: 'Write report',
        start: DateTime.utc(2026, 10, 7, 3, 30), // 09:00 IST, now overdue
      ),
      agendaItem(
        id: 'later',
        date: today,
        title: 'Call',
        start: DateTime.utc(2026, 10, 7, 9, 30), // 15:00 IST
      ),
    ]);
    factory = TaskCubitFactory(tasks: tasks, clock: clock);
  });

  Future<TaskDetailCubit> ready(String id) async {
    final cubit = factory.detail(id)..start();
    addTearDown(cubit.close);
    await cubit.stream.firstWhere((s) => s.status != DetailStatus.loading);
    return cubit;
  }

  test('shows the occurrence with its status and zone-local today', () async {
    final cubit = await ready('occ');
    expect(cubit.state.status, DetailStatus.ready);
    expect(cubit.state.entry?.status, DerivedStatus.overdue);
    expect(cubit.state.entry?.startTime, LocalTime(9, 0));
    expect(cubit.state.today, today);
    expect(cubit.state.canPostponeLaterToday, isTrue);
  });

  test('"in 1 hour" is not offered when it would not push it later', () async {
    final cubit = await ready('later');
    expect(cubit.state.canPostponeLaterToday, isFalse);
  });

  test('an unknown occurrence is reported as not found', () async {
    final cubit = await ready('missing');
    expect(cubit.state.status, DetailStatus.notFound);
  });

  test('actions go through the lifecycle use case', () async {
    final cubit = await ready('occ');

    await cubit.complete(actualDuration: const Duration(minutes: 40));
    await cubit.skip(SkipReason.noTime);
    await cubit.postponeTomorrow();
    await cubit.postponeLaterToday();
    await cubit.saveNote('done early');

    final actions = tasks.actions.map((a) => a.$2).toList();
    expect(
      (actions[0] as CompleteOccurrence).actualDuration,
      const Duration(minutes: 40),
    );
    expect((actions[1] as SkipOccurrence).reason, SkipReason.noTime);
    final tomorrow = actions[2] as PostponeOccurrence;
    expect(tomorrow.toDate, today.addDays(1));
    expect(tomorrow.toTime, LocalTime(9, 0));
    final later = actions[3] as PostponeOccurrence;
    expect(later.toDate, today);
    expect(later.toTime, LocalTime(11, 0));
    expect((actions[4] as UpdateOccurrenceNote).note, 'done early');
  });

  test('a failed action is surfaced and busy is cleared', () async {
    final cubit = await ready('occ');
    tasks.actionFailure = const Failure.conflict(code: 'INVALID_TRANSITION');

    await cubit.reopen();

    expect(cubit.state.actionFailureCount, 1);
    expect(cubit.state.actionFailure, isA<ConflictFailure>());
    expect(cubit.state.busy, isFalse);
  });

  test('deleting the task marks the screen for closing', () async {
    final cubit = await ready('occ');
    await cubit.deleteTask();
    expect(cubit.state.deleted, isTrue);
  });
}
