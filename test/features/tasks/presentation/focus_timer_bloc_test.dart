import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';
import '../../../helpers/test_database.dart';

const _zone = 'Asia/Kolkata';

/// The timer against the real tasks data layer: what it shows comes from
/// persisted work sessions, not from counting.
void main() {
  late FixedClock clock;
  late TasksTestHarness h;
  late ManualTicker ticker;
  final today = LocalDate(2026, 10, 7);

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 3)); // 08:30 in Kolkata
    h = TasksTestHarness(clock: clock);
    ticker = ManualTicker();
  });

  tearDown(() => h.dispose());

  FocusTimerBloc build(FocusTarget target) => FocusTimerBloc(
    target: target,
    watchActiveWork: WatchActiveWork(h.tasks),
    watchAgendaItem: WatchAgendaItem(h.tasks),
    applyAction: ApplyOccurrenceAction(h.tasks),
    workTimer: const WorkTimer(),
    clock: clock,
    ticker: ticker,
  )..add(const FocusTimerSubscribed());

  Future<String> createTask(String title, {int hour = 9}) async {
    await h.tasks.createTask(
      TaskDraft(
        details: TaskDetails(
          title: title,
          plannedDuration: const Duration(minutes: 30),
        ),
        schedule: TaskSchedule(
          startDate: today,
          startTime: LocalTime(hour, 0),
          timeZone: _zone,
        ),
      ),
    );
    final items = (await h.tasks.watchAgenda(from: today, to: today).first)
        .valueOrNull;
    return (items ?? const [])
        .singleWhere((i) => i.task.title == title)
        .occurrence
        .id;
  }

  Future<void> settle() => pumpEventQueue(times: 50);

  test('start → tick → pause → resume → done uses the tracked time', () async {
    final id = await createTask('Write');
    final bloc = build(OccurrenceTarget(id));
    addTearDown(bloc.close);
    await settle();
    expect(bloc.state.load, FocusLoad.ready);
    expect(bloc.state.timer, isNull, reason: 'not started yet');

    bloc.add(const FocusTimerStartPressed());
    await settle();
    expect(bloc.state.running, isTrue);

    clock.current = clock.current.add(const Duration(minutes: 7));
    ticker.tick(clock.current);
    await settle();
    expect(bloc.state.timer?.tracked, const Duration(minutes: 7));

    bloc.add(const FocusTimerPausePressed());
    await settle();
    expect(bloc.state.running, isFalse);

    // Paused time does not count.
    clock.current = clock.current.add(const Duration(minutes: 30));
    bloc.add(const FocusTimerStartPressed());
    await settle();
    clock.current = clock.current.add(const Duration(minutes: 5));
    ticker.tick(clock.current);
    await settle();
    expect(bloc.state.timer?.tracked, const Duration(minutes: 12));

    bloc.add(const FocusTimerCompletePressed());
    await settle();

    final stored = (await h.tasks.watchAgendaItem(id).first).valueOrNull;
    expect(stored?.occurrence.status, OccurrenceStatus.completed);
    expect(stored?.occurrence.actualDuration, const Duration(minutes: 12));
    expect(bloc.state.confirmTracked, isNull);
  });

  test('a forgotten timer asks before completing', () async {
    final id = await createTask('Read');
    final bloc = build(OccurrenceTarget(id));
    addTearDown(bloc.close);
    await settle();
    bloc.add(const FocusTimerStartPressed());
    await settle();

    clock.current = clock.current.add(const Duration(hours: 9));
    bloc.add(const FocusTimerCompletePressed());
    await settle();

    expect(bloc.state.confirmTracked, const Duration(hours: 9));
    expect(bloc.state.confirmCount, 1);
    expect(bloc.state.confirmOccurrenceId, id);
    final notYet = (await h.tasks.watchAgendaItem(id).first).valueOrNull;
    expect(notYet?.occurrence.status, OccurrenceStatus.inProgress);

    bloc.add(
      const FocusTimerCompleteConfirmed(
        actualDuration: Duration(minutes: 40),
      ),
    );
    await settle();
    final done = (await h.tasks.watchAgendaItem(id).first).valueOrNull;
    expect(done?.occurrence.actualDuration, const Duration(minutes: 40));
    expect(bloc.state.confirmTracked, isNull);
    expect(bloc.state.confirmOccurrenceId, isNull);
  });

  test('active work follows whatever was started, and names the paused task',
      () async {
    final first = await createTask('Emails');
    final second = await createTask('Design', hour: 10);
    final active = build(const ActiveWorkTarget());
    addTearDown(active.close);
    await settle();
    expect(active.state.item, isNull);

    active.add(FocusTimerStartPressed(occurrenceId: first));
    await settle();
    expect(active.state.item?.task.title, 'Emails');
    expect(active.state.running, isTrue);

    active.add(FocusTimerStartPressed(occurrenceId: second));
    await settle();
    expect(active.state.item?.task.title, 'Design');
    expect(active.state.autoPausedTitle, 'Emails');
    expect(active.state.noticeCount, 1);

    active.add(const FocusTimerCompletePressed());
    await settle();
    // Design is done; Emails is still paused, so it becomes the active work.
    expect(active.state.item?.task.title, 'Emails');
    expect(active.state.running, isFalse);
  });

  test('a rejected action is reported once and leaves the timer alone',
      () async {
    final id = await createTask('Plan');
    final bloc = build(OccurrenceTarget(id));
    addTearDown(bloc.close);
    await settle();

    bloc.add(const FocusTimerPausePressed()); // nothing is running
    await settle();

    expect(bloc.state.failureCount, 1);
    expect(bloc.state.busy, isFalse);
    expect(bloc.state.timer, isNull);
  });
}
