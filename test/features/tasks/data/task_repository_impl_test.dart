import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_database.dart';

const _zone = 'Asia/Kolkata';

/// The tasks data layer end to end on a real (in-memory) SQLite database.
void main() {
  late FixedClock clock;
  late TasksTestHarness h;
  final today = LocalDate(2026, 10, 7);

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 2)); // 07:30 in Kolkata
    h = TasksTestHarness(clock: clock);
  });

  tearDown(() => h.dispose());

  T ok<T>(Result<T> result) => switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw TestFailure('Expected Ok, got $failure'),
  };

  TaskDraft draft({
    RecurrenceRule rule = const RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
    ),
    LocalTime? time,
    LocalDate? start,
  }) => TaskDraft(
    details: const TaskDetails(
      title: 'Run',
      plannedDuration: Duration(minutes: 30),
    ),
    schedule: TaskSchedule(
      startDate: start ?? today,
      startTime: time ?? LocalTime(9, 0),
      timeZone: _zone,
      rule: rule,
    ),
  );

  /// The repository does not sort; the agenda order comes from the use case.
  Future<List<AgendaItem>> agenda(LocalDate from, LocalDate to) async => [
    ...ok(await h.tasks.watchAgenda(from: from, to: to).first),
  ]..sort(compareAgenda);

  Future<AgendaItem> item(String occurrenceId) async {
    final value = ok(await h.tasks.watchAgendaItem(occurrenceId).first);
    if (value == null) throw TestFailure('No occurrence $occurrenceId');
    return value;
  }

  group('createTask', () {
    test('saves the series, its occurrences and one outbox op', () async {
      final task = ok(await h.tasks.createTask(draft()));

      final items = await agenda(today, today.addDays(30));
      expect(items, hasLength(OccurrencePlanner.horizonDays + 1));
      expect(items.first.task.id, task.id);
      expect(
        items.first.occurrence.scheduledStart,
        DateTime.utc(2026, 10, 7, 3, 30),
      );
      expect(task.materializedThrough, today.addDays(14));

      final ops = await h.outboxRows();
      expect(ops.map((o) => o.type), ['series.create']);
      final payload = jsonDecode(ops.single.payload) as Map<String, dynamic>;
      expect(payload['id'], task.id);
      expect(payload['planned_duration'], 1800);
      expect(payload['start_time'], '09:00');
      expect(payload['recurrence'], containsPair('frequency', 'daily'));
      expect(ops.single.baseVersion, isNull);
    });

    test('materializing again is idempotent', () async {
      ok(await h.tasks.createTask(draft()));
      expect(ok(await h.tasks.materializeOccurrences()), 0);

      clock.current = clock.current.add(const Duration(days: 3));
      expect(ok(await h.tasks.materializeOccurrences()), 3);
      expect(ok(await h.tasks.materializeOccurrences()), 0);
    });
  });

  group('applyAction', () {
    test('start → pause → complete writes state, sessions, events, ops', () async {
      final task = ok(await h.tasks.createTask(draft()));
      final first = (await agenda(today, today)).single.occurrence;

      ok(await h.tasks.applyAction(first.id, const StartOccurrence()));
      clock.current = clock.current.add(const Duration(minutes: 10));
      ok(await h.tasks.applyAction(first.id, const PauseOccurrence()));
      clock.current = clock.current.add(const Duration(minutes: 5));
      ok(await h.tasks.applyAction(first.id, const StartOccurrence()));
      clock.current = clock.current.add(const Duration(minutes: 15));
      final done = ok(
        await h.tasks.applyAction(first.id, const CompleteOccurrence()),
      );

      expect(done.occurrence.actualDuration, const Duration(minutes: 25));
      final stored = await item(first.id);
      expect(stored.occurrence.status, OccurrenceStatus.completed);
      expect(stored.sessions, hasLength(2));
      expect(stored.openSession, isNull);
      expect(stored.task.id, task.id);

      final ops = await h.outboxRows();
      expect(ops.map((o) => o.type), [
        'series.create',
        'occurrence.start',
        'occurrence.pause',
        'occurrence.resume',
        'occurrence.complete',
      ]);
      final complete =
          jsonDecode(ops.last.payload) as Map<String, dynamic>;
      expect(complete['series_id'], task.id);
      expect(complete['original_date'], '2026-10-07');
      expect(complete['actual_duration'], 1500);
      expect(ops.last.entityId, first.id);
      expect(ops.last.baseVersion, 0);
    });

    test('starting a task pauses the one that was running', () async {
      ok(await h.tasks.createTask(draft()));
      ok(await h.tasks.createTask(draft(time: LocalTime(10, 0))));
      final both = await agenda(today, today);
      final a = both[0].occurrence.id;
      final b = both[1].occurrence.id;

      ok(await h.tasks.applyAction(a, const StartOccurrence()));
      clock.current = clock.current.add(const Duration(minutes: 3));
      final outcome = ok(
        await h.tasks.applyAction(b, const StartOccurrence()),
      );

      expect(outcome.autoPausedSession?.occurrenceId, a);
      expect((await item(a)).openSession, isNull);
      expect((await item(b)).openSession, isNotNull);
      final types = (await h.outboxRows()).map((o) => o.type).toList();
      expect(types.sublist(types.length - 2), [
        'occurrence.start',
        'occurrence.pause',
      ]);
    });

    test('a rejected action writes nothing', () async {
      ok(await h.tasks.createTask(draft()));
      final occurrence = (await agenda(today, today)).single.occurrence;
      final before = (await h.outboxRows()).length;

      final result = await h.tasks.applyAction(
        occurrence.id,
        const PauseOccurrence(),
      );

      expect(result.failureOrNull, isA<ConflictFailure>());
      expect((await h.outboxRows()).length, before);
      expect((await item(occurrence.id)).occurrence, occurrence);
    });

    test('postpone moves the occurrence to another day in the agenda', () async {
      ok(await h.tasks.createTask(draft(rule: RecurrenceRule.once)));
      final occurrence = (await agenda(today, today)).single.occurrence;

      ok(
        await h.tasks.applyAction(
          occurrence.id,
          PostponeOccurrence(toDate: today.addDays(1), toTime: LocalTime(18, 0)),
        ),
      );

      expect(await agenda(today, today), isEmpty);
      final moved = (await agenda(today.addDays(1), today.addDays(1))).single;
      expect(moved.occurrence.id, occurrence.id);
      expect(moved.occurrence.postponeCount, 1);
      final op = (await h.outboxRows()).last;
      expect(op.type, 'occurrence.postpone');
      expect(
        jsonDecode(op.payload),
        containsPair('to_start', '2026-10-08T12:30:00.000Z'),
      );
    });

    test('unknown occurrence is not found', () async {
      final result = await h.tasks.applyAction('nope', const StartOccurrence());
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });
  });

  group('editing the series', () {
    test('a new planned duration applies to occurrences not started', () async {
      final task = ok(await h.tasks.createTask(draft()));
      final first = (await agenda(today, today)).single.occurrence;
      ok(await h.tasks.applyAction(first.id, const StartOccurrence()));

      ok(
        await h.tasks.updateTaskDetails(
          task.id,
          const TaskDetails(
            title: 'Long run',
            plannedDuration: Duration(minutes: 45),
          ),
        ),
      );

      final items = await agenda(today, today.addDays(1));
      expect(items[0].occurrence.plannedDuration, const Duration(minutes: 30));
      expect(items[1].occurrence.plannedDuration, const Duration(minutes: 45));
      expect(items[1].task.title, 'Long run');
      expect((await h.outboxRows()).last.type, 'series.update');
    });

    test('rescheduling from a later date splits the series', () async {
      final task = ok(await h.tasks.createTask(draft()));
      final first = (await agenda(today, today)).single.occurrence;
      ok(await h.tasks.applyAction(first.id, const CompleteOccurrence()));
      final splitDate = today.addDays(3);

      final successor = ok(
        await h.tasks.rescheduleFrom(
          task.id,
          fromDate: splitDate,
          schedule: TaskSchedule(
            startDate: splitDate,
            startTime: LocalTime(18, 0),
            timeZone: _zone,
            rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
          ),
        ),
      );

      expect(successor.id, isNot(task.id));
      expect(successor.lineageId, task.lineageId);
      final old = ok(await h.tasks.getTask(task.id));
      expect(old.endedOn, splitDate.addDays(-1));

      final items = await agenda(today, splitDate);
      expect(items.map((i) => i.task.id), [
        task.id,
        task.id,
        task.id,
        successor.id,
      ]);
      // History is untouched.
      expect(items.first.occurrence.status, OccurrenceStatus.completed);
      expect(
        items.last.occurrence.scheduledStart,
        DateTime.utc(2026, 10, 10, 12, 30),
      );

      final op = (await h.outboxRows()).last;
      expect(op.type, 'series.split');
      final payload = jsonDecode(op.payload) as Map<String, dynamic>;
      expect(payload['split_date'], '2026-10-10');
      expect(payload['new_series'], containsPair('id', successor.id));
    });

    test('a split does not double-book a day the user already touched', () async {
      final task = ok(await h.tasks.createTask(draft()));
      final splitDate = today.addDays(2);
      final touched = (await agenda(splitDate, splitDate)).single.occurrence;
      ok(
        await h.tasks.applyAction(
          touched.id,
          const UpdateOccurrenceNote('bring shoes'),
        ),
      );

      final successor = ok(
        await h.tasks.rescheduleFrom(
          task.id,
          fromDate: splitDate,
          schedule: TaskSchedule(
            startDate: splitDate,
            startTime: LocalTime(18, 0),
            timeZone: _zone,
            rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
          ),
        ),
      );

      final onSplitDay = await agenda(splitDate, splitDate);
      expect(onSplitDay.single.occurrence.id, touched.id);
      final nextDay = await agenda(splitDate.addDays(1), splitDate.addDays(1));
      expect(nextDay.single.task.id, successor.id);
    });

    test('moving a one-off task to a later day edits it in place', () async {
      final task = ok(await h.tasks.createTask(draft(rule: RecurrenceRule.once)));
      final later = today.addDays(3);

      final moved = ok(
        await h.tasks.rescheduleFrom(
          task.id,
          fromDate: later,
          schedule: TaskSchedule(
            startDate: later,
            startTime: LocalTime(18, 0),
            timeZone: _zone,
          ),
        ),
      );

      expect(moved.id, task.id);
      expect(await agenda(today, today), isEmpty);
      final items = await agenda(today, today.addDays(14));
      expect(items.single.occurrence.scheduledDate, later);
      expect((await h.outboxRows()).last.type, 'series.update');
    });

    test('a postponed one-off moves as the same occurrence', () async {
      final task = ok(await h.tasks.createTask(draft(rule: RecurrenceRule.once)));
      final occurrence = (await agenda(today, today)).single.occurrence;
      ok(
        await h.tasks.applyAction(
          occurrence.id,
          const UpdateOccurrenceNote('bring charger'),
        ),
      );

      ok(
        await h.tasks.rescheduleFrom(
          task.id,
          fromDate: today.addDays(2),
          schedule: TaskSchedule(startDate: today.addDays(2), timeZone: _zone),
        ),
      );
      expect(ok(await h.tasks.materializeOccurrences()), 0);

      final items = await agenda(today, today.addDays(14));
      expect(items.single.occurrence.id, occurrence.id);
      expect(items.single.occurrence.note, 'bring charger');
      expect(items.single.occurrence.scheduledDate, today.addDays(2));
      expect(items.single.occurrence.scheduledStart, isNull);
    });

    test('a finished one-off cannot be moved', () async {
      final task = ok(await h.tasks.createTask(draft(rule: RecurrenceRule.once)));
      final occurrence = (await agenda(today, today)).single.occurrence;
      ok(await h.tasks.applyAction(occurrence.id, const CompleteOccurrence()));

      final result = await h.tasks.rescheduleFrom(
        task.id,
        fromDate: today.addDays(1),
        schedule: TaskSchedule(startDate: today.addDays(1), timeZone: _zone),
      );

      expect(
        result.failureOrNull,
        const Failure.validation(
          fieldErrors: {TaskFields.startDate: TaskRuleCodes.alreadyResolved},
        ),
      );
    });

    test('rescheduling from the start date edits in place', () async {
      final task = ok(await h.tasks.createTask(draft()));
      final edited = ok(
        await h.tasks.rescheduleFrom(
          task.id,
          fromDate: today,
          schedule: TaskSchedule(
            startDate: today,
            startTime: LocalTime(6, 0),
            timeZone: _zone,
            rule: const RecurrenceRule(
              frequency: RecurrenceFrequency.weekly,
              weekdays: [3],
            ),
          ),
        ),
      );

      expect(edited.id, task.id);
      final items = await agenda(today, today.addDays(14));
      expect(items, hasLength(3)); // Wednesdays: 7th, 14th, 21st
      expect(
        items.first.occurrence.scheduledStart,
        DateTime.utc(2026, 10, 7, 0, 30),
      );
    });

    test('ending keeps today and removes untouched later occurrences', () async {
      final task = ok(await h.tasks.createTask(draft()));
      final tomorrow = (await agenda(today.addDays(1), today.addDays(1)))
          .single
          .occurrence;
      ok(
        await h.tasks.applyAction(
          tomorrow.id,
          const UpdateOccurrenceNote('keep me'),
        ),
      );

      ok(await h.tasks.endTask(task.id, lastDate: today));

      final items = await agenda(today, today.addDays(14));
      expect(items.map((i) => i.occurrence.originalDate), [
        today,
        today.addDays(1), // annotated, so it is history
      ]);
      expect(ok(await h.tasks.materializeOccurrences()), 0);
      expect(ok(await h.tasks.getTask(task.id)).endedOn, today);
    });

    test('delete hides the series and its occurrences', () async {
      final task = ok(await h.tasks.createTask(draft()));
      ok(await h.tasks.deleteTask(task.id));

      expect(await agenda(today, today.addDays(14)), isEmpty);
      expect(
        (await h.tasks.getTask(task.id)).failureOrNull,
        isA<NotFoundFailure>(),
      );
      expect((await h.outboxRows()).last.type, 'series.delete');
    });
  });

  test('watchAgenda emits again when an occurrence changes', () async {
    ok(await h.tasks.createTask(draft(rule: RecurrenceRule.once)));
    final occurrence = (await agenda(today, today)).single.occurrence;

    final statuses = <OccurrenceStatus?>[];
    final first = Completer<void>();
    final second = Completer<void>();
    final subscription = h.tasks.watchAgenda(from: today, to: today).listen((
      result,
    ) {
      statuses.add(result.valueOrNull?.single.occurrence.status);
      if (statuses.length == 1) first.complete();
      if (statuses.length == 2) second.complete();
    });
    addTearDown(subscription.cancel);

    await first.future;
    ok(await h.tasks.applyAction(occurrence.id, const StartOccurrence()));
    await second.future;

    expect(statuses, [
      OccurrenceStatus.scheduled,
      OccurrenceStatus.inProgress,
    ]);
  });

  test('watchInProgress lists started, unresolved occurrences', () async {
    ok(await h.tasks.createTask(draft()));
    final first = (await agenda(today, today)).single.occurrence;
    expect(ok(await h.tasks.watchInProgress().first), isEmpty);

    ok(await h.tasks.applyAction(first.id, const StartOccurrence()));
    final running = ok(await h.tasks.watchInProgress().first);
    expect(running.single.occurrence.id, first.id);
    expect(running.single.openSession, isNotNull);

    ok(await h.tasks.applyAction(first.id, const CompleteOccurrence()));
    expect(ok(await h.tasks.watchInProgress().first), isEmpty);
  });

  test('watchLineage follows an activity across a split', () async {
    final task = ok(await h.tasks.createTask(draft()));
    ok(await h.tasks.createTask(draft(time: LocalTime(18, 0))));
    final splitDate = today.addDays(3);
    final successor = ok(
      await h.tasks.rescheduleFrom(
        task.id,
        fromDate: splitDate,
        schedule: TaskSchedule(
          startDate: splitDate,
          startTime: LocalTime(7, 0),
          timeZone: _zone,
          rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        ),
      ),
    );

    final items = ok(
      await h.tasks
          .watchLineage(task.lineageId, from: today, to: today.addDays(5))
          .first,
    );
    expect(items, hasLength(6), reason: 'the other task is not included');
    expect(
      items.map((i) => i.task.id).toSet(),
      {task.id, successor.id},
    );
    expect(items.every((i) => i.task.lineageId == task.lineageId), isTrue);
  });

  test('no unexpected errors were reported', () async {
    ok(await h.tasks.createTask(draft()));
    expect(h.reporter.errors, isEmpty);
  });
}
