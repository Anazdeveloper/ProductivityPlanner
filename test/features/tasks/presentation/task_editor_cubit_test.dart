import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  final today = LocalDate(2026, 10, 7); // Wednesday
  late FixedClock clock;
  late FakeTaskRepository tasks;
  late TaskCubitFactory factory;

  setUp(() {
    clock = FixedClock(DateTime.utc(2026, 10, 7, 4, 40)); // 10:10 IST
    tasks = FakeTaskRepository([
      agendaItem(
        id: 'occ',
        date: LocalDate(2026, 10, 1),
        title: 'Run',
        wallTime: LocalTime(7, 0),
        rule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          weekdays: [1, 3, 5],
        ),
      ),
    ]);
    factory = TaskCubitFactory(tasks: tasks, clock: clock);
  });

  Future<TaskEditorCubit> loaded(TaskEditorArgs args) async {
    final cubit = factory.editor(args);
    addTearDown(cubit.close);
    cubit.load();
    await cubit.stream.firstWhere((s) => s.status == EditorStatus.editing);
    return cubit;
  }

  group('create', () {
    test('prefills today, the next half hour and the quick-add title', () async {
      final cubit = await loaded(const TaskEditorArgs.create(title: ' Read '));
      final state = cubit.state;
      expect(state.timeZone, 'Asia/Kolkata');
      expect(state.today, today);
      expect(state.date, today);
      expect(state.time, LocalTime(10, 30));
      expect(state.title, 'Read');
      expect(state.reminder, const Duration(minutes: 5));
      expect(state.canSubmit, isTrue);
    });

    test('a requested past date is clamped to today', () async {
      final cubit = await loaded(
        TaskEditorArgs.create(date: today.addDays(-2)),
      );
      expect(cubit.state.date, today);
    });

    test('a future date defaults to 09:00', () async {
      final cubit = await loaded(TaskEditorArgs.create(date: today.addDays(2)));
      expect(cubit.state.time, LocalTime(9, 0));
    });

    test('saves a weekly task with a reminder', () async {
      final cubit = await loaded(const TaskEditorArgs.create());
      cubit
        ..titleChanged('Gym')
        ..frequencyChanged(RecurrenceFrequency.weekly)
        ..weekdayToggled(5)
        ..durationChanged(const Duration(hours: 1));
      expect(cubit.state.weekdays, [3, 5]);

      await cubit.submit();

      expect(cubit.state.status, EditorStatus.saved);
      final draft = tasks.created.single;
      expect(draft.details.title, 'Gym');
      expect(draft.details.plannedDuration, const Duration(hours: 1));
      expect(draft.details.reminderOffsets, const [Duration(minutes: 5)]);
      expect(draft.schedule.rule.frequency, RecurrenceFrequency.weekly);
      expect(draft.schedule.rule.weekdays, [3, 5]);
      expect(draft.schedule.startTime, LocalTime(10, 30));
    });

    test('an any-time task saves without a reminder', () async {
      final cubit = await loaded(const TaskEditorArgs.create());
      cubit
        ..titleChanged('Groceries')
        ..timeChanged(null);
      await cubit.submit();
      expect(tasks.created.single.details.reminderOffsets, isEmpty);
      expect(tasks.created.single.schedule.startTime, isNull);
    });

    test('the last weekday cannot be removed', () async {
      final cubit = await loaded(const TaskEditorArgs.create());
      cubit
        ..frequencyChanged(RecurrenceFrequency.weekly)
        ..weekdayToggled(3);
      expect(cubit.state.weekdays, [3]);
    });

    test('domain validation errors land on the fields and clear on edit', () async {
      final cubit = await loaded(const TaskEditorArgs.create());
      cubit
        ..titleChanged('   ')
        ..dateChanged(today.addDays(-1));

      await cubit.submit();

      expect(cubit.state.status, EditorStatus.editing);
      expect(cubit.state.fieldErrors, {
        TaskFields.title: TaskRuleCodes.required,
        TaskFields.startDate: TaskRuleCodes.inPast,
      });
      expect(tasks.created, isEmpty);

      cubit.titleChanged('Fixed');
      expect(cubit.state.fieldErrors.keys, [TaskFields.startDate]);
    });

    test('monthly pins the day of month from the date', () async {
      final cubit = await loaded(const TaskEditorArgs.create());
      cubit
        ..titleChanged('Rent')
        ..frequencyChanged(RecurrenceFrequency.monthly)
        ..repeatEndChanged(RepeatEnd.afterCount)
        ..countChanged(6);
      await cubit.submit();
      final rule = tasks.created.single.schedule.rule;
      expect(rule.monthDay, 7);
      expect(rule.count, 6);
      expect(rule.until, isNull);
    });
  });

  group('edit', () {
    test('prefills from the task; changes apply from today at the earliest', () async {
      final cubit = await loaded(
        TaskEditorArgs.edit(taskId: 'task-occ', editFrom: today.addDays(-3)),
      );
      final state = cubit.state;
      expect(state.title, 'Run');
      expect(state.time, LocalTime(7, 0));
      expect(state.frequency, RecurrenceFrequency.weekly);
      expect(state.weekdays, [1, 3, 5]);
      expect(state.editsFromDate, isTrue);
      expect(state.editFrom, today);
    });

    test('a details-only change does not touch the schedule', () async {
      final cubit = await loaded(const TaskEditorArgs.edit(taskId: 'task-occ'));
      cubit.titleChanged('Long run');
      await cubit.submit();

      expect(cubit.state.status, EditorStatus.saved);
      expect(tasks.detailUpdates.single.$2.title, 'Long run');
      expect(tasks.reschedules, isEmpty);
    });

    test('a schedule change reschedules from the edit date', () async {
      final cubit = await loaded(
        TaskEditorArgs.edit(taskId: 'task-occ', editFrom: today.addDays(2)),
      );
      cubit.timeChanged(LocalTime(18, 0));
      await cubit.submit();

      expect(tasks.detailUpdates, isEmpty);
      final (id, from, schedule) = tasks.reschedules.single;
      expect(id, 'task-occ');
      expect(from, today.addDays(2));
      expect(schedule.startTime, LocalTime(18, 0));
      expect(schedule.rule.weekdays, [1, 3, 5]);
    });

    test('an unknown task fails to load', () async {
      final cubit = factory.editor(const TaskEditorArgs.edit(taskId: 'nope'));
      addTearDown(cubit.close);
      cubit.load();
      final state = await cubit.stream.firstWhere(
        (s) => s.status == EditorStatus.loadFailed,
      );
      expect(state.failure, isNotNull);
    });
  });
}
