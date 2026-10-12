import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/analytics_cubit.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_feature_access.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  final today = LocalDate(2026, 10, 7); // Wednesday
  late FakeTaskRepository tasks;
  late FixedClock clock;
  late ManualTicker ticker;
  late TaskCubitFactory factory;

  setUp(() {
    tasks = FakeTaskRepository([
      agendaItem(
        id: 'last-week',
        date: LocalDate(2026, 9, 30),
        lineageId: 'run',
        title: 'Run',
        status: OccurrenceStatus.completed,
      ),
      agendaItem(
        id: 'mon',
        date: LocalDate(2026, 10, 5),
        lineageId: 'run',
        title: 'Run',
        status: OccurrenceStatus.completed,
        actual: const Duration(minutes: 40),
      ),
      agendaItem(
        id: 'tue',
        date: LocalDate(2026, 10, 6),
        lineageId: 'run',
        title: 'Run',
      ),
      agendaItem(id: 'wed', date: today, lineageId: 'run', title: 'Run'),
    ]);
    // 12:00 in Kolkata (the fake home zone).
    clock = FixedClock(DateTime.utc(2026, 10, 7, 6, 30));
    ticker = ManualTicker();
    factory = TaskCubitFactory(tasks: tasks, clock: clock, ticker: ticker);
  });

  Future<void> settle() => pumpEventQueue();

  test('opens on this week with live metrics', () async {
    final cubit = factory.analytics();
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    expect(cubit.state.period.start, LocalDate(2026, 10, 5));
    expect(cubit.state.load, AnalyticsLoad.ready);
    final metrics = cubit.state.report?.metrics;
    expect(metrics?.completed, 1);
    expect(metrics?.missed, 1);
    expect(metrics?.open, 1);
    expect(cubit.state.report?.previous.completed, 1);
    expect(cubit.state.canGoNext, isFalse);
    expect(cubit.state.canGoBack, isTrue);

    tasks.items = [
      for (final item in tasks.items)
        item.occurrence.id == 'wed'
            ? item.copyWith(
                occurrence: item.occurrence.copyWith(
                  status: OccurrenceStatus.completed,
                ),
              )
            : item,
    ];
    await settle();
    expect(cubit.state.report?.metrics.completed, 2);
  });

  test('moves between periods but never past the present', () async {
    final cubit = factory.analytics();
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    cubit.previous();
    await settle();
    expect(cubit.state.period.start, LocalDate(2026, 9, 28));
    expect(cubit.state.report?.metrics.completed, 1);
    expect(cubit.state.isCurrent, isFalse);

    cubit
      ..next()
      ..next();
    await settle();
    expect(cubit.state.period.start, LocalDate(2026, 10, 5));
  });

  test('switching kind keeps the place in time', () async {
    final cubit = factory.analytics();
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    cubit.selectKind(PeriodKind.month);
    await settle();
    expect(cubit.state.period.start, LocalDate(2026, 10, 1));
    expect(cubit.state.period.end, LocalDate(2026, 10, 31));
    expect(cubit.state.report?.days, hasLength(31));

    cubit.selectKind(PeriodKind.day);
    await settle();
    expect(cubit.state.period.start, today);
    expect(cubit.state.report?.executions.single.record.occurrenceId, 'wed');
  });

  test('a tapped bar opens that day; future days are ignored', () async {
    final cubit = factory.analytics();
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    cubit.showDay(LocalDate(2026, 10, 9));
    expect(cubit.state.period.kind, PeriodKind.week);

    cubit.showDay(LocalDate(2026, 10, 5));
    await settle();
    expect(cubit.state.period.kind, PeriodKind.day);
    expect(cubit.state.period.start, LocalDate(2026, 10, 5));
  });

  test('the plan history window stops going back', () async {
    final cubit = factory.analytics(
      access: const FakeFeatureAccess(historyDays: 30),
    );
    addTearDown(cubit.close);
    cubit.start();
    await settle();
    expect(cubit.state.access.earliestDate, LocalDate(2026, 9, 8));

    for (var i = 0; i < 6; i++) {
      cubit.previous();
    }
    await settle();
    // The week of Sep 7 still holds days inside the window; no further.
    expect(cubit.state.period.start, LocalDate(2026, 9, 7));
    expect(cubit.state.canGoBack, isFalse);
    expect(cubit.state.historyLimited, isTrue);
  });

  test('follows the present when the week rolls over', () async {
    final cubit = factory.analytics();
    addTearDown(cubit.close);
    cubit.start();
    await settle();

    clock.current = DateTime.utc(2026, 10, 12, 6, 30); // next Monday
    ticker.tick(clock.current);
    await settle();

    expect(cubit.state.today, LocalDate(2026, 10, 12));
    expect(cubit.state.period.start, LocalDate(2026, 10, 12));
  });
}
