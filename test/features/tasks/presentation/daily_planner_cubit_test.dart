import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  final today = LocalDate(2026, 10, 7); // a Wednesday
  late FixedClock clock;
  late FakeTaskRepository tasks;
  late ManualTicker ticker;
  late TaskCubitFactory factory;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 4, 30)); // 10:00 IST
    tasks = FakeTaskRepository([
      agendaItem(
        id: 'morning',
        date: today,
        title: 'Run',
        start: DateTime.utc(2026, 10, 7, 1, 30), // 07:00 IST
        status: OccurrenceStatus.completed,
      ),
      agendaItem(
        id: 'noon',
        date: today,
        title: 'Lunch walk',
        start: DateTime.utc(2026, 10, 7, 6, 30), // 12:00 IST
      ),
      agendaItem(id: 'friday', date: LocalDate(2026, 10, 9), title: 'Review'),
    ]);
    ticker = ManualTicker();
    factory = TaskCubitFactory(tasks: tasks, clock: clock, ticker: ticker);
  });

  Future<DailyPlannerState> started(DailyPlannerCubit cubit) {
    cubit.start();
    return cubit.stream.firstWhere((s) => s.load == PlannerLoad.ready);
  }

  test('day scope shows today with progress and the next task', () async {
    final cubit = factory.planner(PlannerScope.day);
    addTearDown(cubit.close);

    final state = await started(cubit);

    expect(state.today, today);
    expect(state.dayEntries.map((e) => e.occurrenceId), ['morning', 'noon']);
    expect(state.summary.completed, 1);
    expect(state.summary.total, 2);
    expect(state.summary.next?.occurrenceId, 'noon');
  });

  test('week scope loads Monday to Sunday and switches days locally', () async {
    final cubit = factory.planner(PlannerScope.week);
    addTearDown(cubit.close);

    final state = await started(cubit);
    expect(state.rangeStart, LocalDate(2026, 10, 5));
    expect(state.rangeEnd, LocalDate(2026, 10, 11));
    expect(state.rangeSummaries[LocalDate(2026, 10, 9)]?.total, 1);

    cubit.selectDay(LocalDate(2026, 10, 9));
    expect(cubit.state.dayEntries.single.occurrenceId, 'friday');
    expect(cubit.state.isToday, isFalse);

    cubit.nextWeek();
    expect(cubit.state.rangeStart, LocalDate(2026, 10, 12));
    expect(cubit.state.load, PlannerLoad.loading);
    final next = await cubit.stream.firstWhere(
      (s) => s.load == PlannerLoad.ready,
    );
    expect(next.dayEntries, isEmpty);

    cubit.goToToday();
    expect(cubit.state.selectedDay, today);
  });

  test('toggle completes an open task and reopens a done one', () async {
    final cubit = factory.planner(PlannerScope.day);
    addTearDown(cubit.close);
    await started(cubit);

    await cubit.toggleComplete('noon');
    await cubit.toggleComplete('morning');

    expect(tasks.actions.map((a) => (a.$1, a.$2.runtimeType)), [
      ('noon', CompleteOccurrence),
      ('morning', ReopenOccurrence),
    ]);
    expect(cubit.state.busy, isEmpty);
  });

  test('a failed action is reported once and clears busy', () async {
    final cubit = factory.planner(PlannerScope.day);
    addTearDown(cubit.close);
    await started(cubit);
    tasks.actionFailure = const Failure.database();

    await cubit.toggleComplete('noon');

    expect(cubit.state.actionFailure, const Failure.database());
    expect(cubit.state.actionFailureCount, 1);
    expect(cubit.state.busy, isEmpty);
  });

  test('quick add creates an any-time task today in the home zone', () async {
    final cubit = factory.planner(PlannerScope.day);
    addTearDown(cubit.close);
    await started(cubit);

    expect(await cubit.quickAdd('  Call mom '), isTrue);
    expect(await cubit.quickAdd('   '), isFalse);

    final draft = tasks.created.single;
    expect(draft.details.title, 'Call mom');
    expect(draft.details.plannedDuration, DailyPlannerCubit.quickAddDuration);
    expect(draft.schedule.startDate, today);
    expect(draft.schedule.startTime, isNull);
    expect(draft.schedule.timeZone, 'Asia/Kolkata');
  });

  test('quick add on a past day plans it for today', () async {
    final cubit = factory.planner(PlannerScope.week);
    addTearDown(cubit.close);
    await started(cubit);
    cubit.selectDay(LocalDate(2026, 10, 5));

    await cubit.quickAdd('Catch up');

    expect(tasks.created.single.schedule.startDate, today);
  });

  test('ticks refresh statuses and roll over at midnight', () async {
    final cubit = factory.planner(PlannerScope.day);
    addTearDown(cubit.close);
    await started(cubit);
    expect(cubit.state.dayEntries[1].status, DerivedStatus.upcoming);

    clock.current = DateTime.utc(2026, 10, 7, 6, 35); // 12:05 IST
    ticker.tick(clock.current);
    final due = await cubit.stream.firstWhere(
      (s) => s.dayEntries.length == 2 && s.dayEntries[1].status == DerivedStatus.due,
    );
    expect(due.now, clock.current);

    clock.current = DateTime.utc(2026, 10, 7, 18, 35); // 00:05 IST on the 8th
    ticker.tick(clock.current);
    final rolled = await cubit.stream.firstWhere(
      (s) => s.selectedDay == LocalDate(2026, 10, 8) &&
          s.load == PlannerLoad.ready,
    );
    expect(rolled.today, LocalDate(2026, 10, 8));
    expect(rolled.dayEntries, isEmpty);
  });
}
