import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/create_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/edit_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';

part 'task_editor_cubit.freezed.dart';

/// What the editor was opened for.
final class TaskEditorArgs {
  const TaskEditorArgs.create({this.date, this.title, this.prefill})
    : taskId = null,
      editFrom = null;

  const TaskEditorArgs.edit({required String this.taskId, this.editFrom})
    : date = null,
      title = null,
      prefill = null;

  /// Set when editing.
  final String? taskId;

  /// Create: prefilled date (e.g. the day selected in Planner).
  final LocalDate? date;

  /// Create: prefilled title (from quick add).
  final String? title;

  /// Create: suggested values (from voice). Wins over [date] and [title].
  final TaskPrefill? prefill;

  /// Edit of a repeating task: first date schedule changes apply to (the
  /// occurrence it was opened from). Clamped to today.
  final LocalDate? editFrom;

  bool get isEdit => taskId != null;
}

enum EditorStatus { loading, editing, saving, saved, loadFailed }

enum RepeatEnd { never, onDate, afterCount }

@freezed
abstract class TaskEditorState with _$TaskEditorState {
  const factory TaskEditorState({
    required bool isEdit,
    required LocalDate today,
    required LocalDate date,
    @Default(EditorStatus.loading) EditorStatus status,
    @Default('') String title,
    @Default('') String notes,

    /// Null = any time that day.
    LocalTime? time,
    @Default(Duration(minutes: 30)) Duration duration,
    @Default(TaskPriority.medium) TaskPriority priority,
    String? categoryId,
    @Default(RecurrenceFrequency.none) RecurrenceFrequency frequency,
    @Default(1) int interval,
    @Default(<int>[]) List<int> weekdays,
    @Default(RepeatEnd.never) RepeatEnd repeatEnd,
    LocalDate? until,
    @Default(10) int count,

    /// Null = no reminder.
    @Default(Duration(minutes: 5)) Duration? reminder,
    @Default('UTC') String timeZone,
    @Default(<Category>[]) List<Category> categories,

    /// `TaskFields` key → `TaskRuleCodes` value.
    @Default(<String, String>{}) Map<String, String> fieldErrors,
    Failure? failure,

    /// Edit mode: the task being edited and where schedule changes start.
    Task? original,
    LocalDate? editFrom,

    /// What a prefill was made from (e.g. the spoken sentence).
    String? originText,
  }) = _TaskEditorState;

  const TaskEditorState._();

  bool get isRepeating => frequency != RecurrenceFrequency.none;

  /// Editing a repeating task changes it from [editFrom] on; its start date
  /// is not edited directly.
  bool get editsFromDate => isEdit && (original?.isRecurring ?? false);

  bool get canSubmit =>
      status == EditorStatus.editing && title.trim().isNotEmpty;
}

/// The task form (create and edit). A Cubit: each field change is a plain
/// state update; the rules live in the domain (`TaskRules` via the use
/// cases), whose field errors are shown next to the fields.
final class TaskEditorCubit extends Cubit<TaskEditorState> {
  TaskEditorCubit({
    required this.args,
    required CreateTask createTask,
    required UpdateTaskDetails updateTaskDetails,
    required RescheduleTaskFrom rescheduleTaskFrom,
    required GetTask getTask,
    required GetHomeTimeZone getHomeTimeZone,
    required WatchCategories watchCategories,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _createTask = createTask,
       _updateTaskDetails = updateTaskDetails,
       _rescheduleTaskFrom = rescheduleTaskFrom,
       _getTask = getTask,
       _getHomeTimeZone = getHomeTimeZone,
       _watchCategories = watchCategories,
       _converter = converter,
       _clock = clock,
       super(
         TaskEditorState(
           isEdit: args.isEdit,
           today: LocalDate.fromDateTime(clock.now()),
           date: LocalDate.fromDateTime(clock.now()),
         ),
       );

  final TaskEditorArgs args;
  final CreateTask _createTask;
  final UpdateTaskDetails _updateTaskDetails;
  final RescheduleTaskFrom _rescheduleTaskFrom;
  final GetTask _getTask;
  final GetHomeTimeZone _getHomeTimeZone;
  final WatchCategories _watchCategories;
  final TimeZoneConverter _converter;
  final Clock _clock;

  StreamSubscription<Result<List<Category>>>? _categories;

  /// Resolves the zone and today, loads the task when editing, and
  /// prefills the form. Call once after creation.
  void load() => unawaited(_load());

  Future<void> _load() async {
    _categories ??= _watchCategories(const NoParams()).listen((result) {
      if (result case Ok(:final value)) {
        emit(state.copyWith(categories: value));
      }
    });

    final taskId = args.taskId;
    if (taskId == null) {
      final zone = (await _getHomeTimeZone(const NoParams())).valueOrNull;
      if (isClosed) return;
      _prefillNew(zone ?? 'UTC');
      return;
    }

    final result = await _getTask(taskId);
    if (isClosed) return;
    switch (result) {
      case Ok(:final value):
        _prefillEdit(value);
      case Err(:final failure):
        emit(state.copyWith(status: EditorStatus.loadFailed, failure: failure));
    }
  }

  void _prefillNew(String zone) {
    final now = _clock.now();
    final today = _converter.localDate(now, zone);
    final prefill = args.prefill;
    final requested = prefill?.date ?? args.date;
    final date = requested == null ? today : maxDate(requested, today);
    // Next half hour in the task's zone; any-time if that is past today.
    final slot = _nextHalfHour(now, zone);
    final defaultTime = slot.date == date
        ? slot.time
        : (date > today ? _morning : null);
    final rule = prefill?.recurrence;
    final duration = prefill?.duration;
    emit(
      state.copyWith(
        status: EditorStatus.editing,
        timeZone: zone,
        today: today,
        date: date,
        time: (prefill?.anyTime ?? false)
            ? null
            : (prefill?.time ?? defaultTime),
        title: (prefill?.title ?? args.title)?.trim() ?? '',
        duration: duration ?? state.duration,
        categoryId: prefill?.categoryId ?? state.categoryId,
        frequency: rule?.frequency ?? state.frequency,
        interval: rule == null || rule.interval < 1 ? 1 : rule.interval,
        weekdays: rule == null
            ? state.weekdays
            : (rule.frequency == RecurrenceFrequency.weekly &&
                      rule.weekdays.isEmpty
                  ? [date.weekday]
                  : rule.weekdays),
        originText: prefill?.originText,
      ),
    );
  }

  void _prefillEdit(Task task) {
    final schedule = _normalized(task.schedule);
    final rule = schedule.rule;
    final zone = _converter.isValidZone(schedule.timeZone)
        ? schedule.timeZone
        : 'UTC';
    final today = _converter.localDate(_clock.now(), zone);
    final requestedFrom = args.editFrom ?? today;
    final until = rule.until;
    final count = rule.count;
    emit(
      state.copyWith(
        status: EditorStatus.editing,
        original: task,
        editFrom: maxDate(requestedFrom, today),
        timeZone: schedule.timeZone,
        today: today,
        date: schedule.startDate,
        time: schedule.startTime,
        title: task.title,
        notes: task.notes ?? '',
        duration: task.plannedDuration,
        priority: task.priority,
        categoryId: task.categoryId,
        frequency: rule.frequency,
        interval: rule.interval,
        weekdays: rule.weekdays,
        repeatEnd: until != null
            ? RepeatEnd.onDate
            : (count != null ? RepeatEnd.afterCount : RepeatEnd.never),
        until: until,
        count: count ?? state.count,
        reminder: task.reminderOffsets.isEmpty
            ? null
            : task.reminderOffsets.first,
      ),
    );
  }

  /// Makes rule defaults explicit (weekly days, day of month), so a later
  /// split keeps them and "unchanged" compares like with like.
  static TaskSchedule _normalized(TaskSchedule schedule) {
    final rule = schedule.rule;
    return schedule.copyWith(
      rule: rule.copyWith(
        weekdays:
            rule.frequency == RecurrenceFrequency.weekly && rule.weekdays.isEmpty
            ? [schedule.startDate.weekday]
            : rule.weekdays,
        monthDay: rule.frequency == RecurrenceFrequency.monthly
            ? (rule.monthDay ?? schedule.startDate.day)
            : rule.monthDay,
      ),
    );
  }

  static final _morning = LocalTime(9, 0);

  ({LocalDate date, LocalTime time}) _nextHalfHour(DateTime now, String zone) {
    const step = 30 * 60 * 1000;
    final millis = now.millisecondsSinceEpoch;
    final next = DateTime.fromMillisecondsSinceEpoch(
      (millis ~/ step + 1) * step,
      isUtc: true,
    );
    return (
      date: _converter.localDate(next, zone),
      time: _converter.localTime(next, zone),
    );
  }

  // Field changes. Each clears that field's error.

  void titleChanged(String value) =>
      _update(state.copyWith(title: value), TaskFields.title);

  void notesChanged(String value) =>
      _update(state.copyWith(notes: value), TaskFields.notes);

  void dateChanged(LocalDate value) =>
      _update(state.copyWith(date: value), TaskFields.startDate);

  void timeChanged(LocalTime? value) => _update(state.copyWith(time: value));

  void durationChanged(Duration value) =>
      _update(state.copyWith(duration: value), TaskFields.plannedDuration);

  void priorityChanged(TaskPriority value) =>
      _update(state.copyWith(priority: value));

  void categoryChanged(String? value) =>
      _update(state.copyWith(categoryId: value));

  void frequencyChanged(RecurrenceFrequency value) => _update(
    state.copyWith(
      frequency: value,
      interval: 1,
      weekdays: value == RecurrenceFrequency.weekly && state.weekdays.isEmpty
          ? [_scheduleStart.weekday]
          : state.weekdays,
    ),
    TaskFields.interval,
  );

  void intervalChanged(int value) => _update(
    state.copyWith(interval: value < 1 ? 1 : value),
    TaskFields.interval,
  );

  /// Toggles an ISO weekday; the last selected day cannot be removed.
  void weekdayToggled(int weekday) {
    final days = {...state.weekdays};
    if (days.contains(weekday)) {
      if (days.length == 1) return;
      days.remove(weekday);
    } else {
      days.add(weekday);
    }
    _update(
      state.copyWith(weekdays: days.toList()..sort()),
      TaskFields.weekdays,
    );
  }

  void repeatEndChanged(RepeatEnd value) => _update(
    state.copyWith(
      repeatEnd: value,
      until: value == RepeatEnd.onDate
          ? (state.until ?? _scheduleStart.addDays(30))
          : state.until,
    ),
    TaskFields.until,
  );

  void untilChanged(LocalDate value) =>
      _update(state.copyWith(until: value), TaskFields.until);

  void countChanged(int value) =>
      _update(state.copyWith(count: value), TaskFields.count);

  void reminderChanged(Duration? value) =>
      _update(state.copyWith(reminder: value), TaskFields.reminderOffsets);

  void _update(TaskEditorState next, [String? clearsField]) {
    if (state.status != EditorStatus.editing) return;
    final errors = clearsField == null || !next.fieldErrors.containsKey(clearsField)
        ? next.fieldErrors
        : ({...next.fieldErrors}..remove(clearsField));
    emit(next.copyWith(fieldErrors: errors, failure: null));
  }

  /// The date the schedule being edited starts on.
  LocalDate get _scheduleStart =>
      state.editsFromDate ? (state.editFrom ?? state.date) : state.date;

  // Saving

  Future<void> submit() async {
    if (state.status != EditorStatus.editing) return;
    emit(state.copyWith(status: EditorStatus.saving, failure: null));
    final result = state.isEdit ? await _saveEdit() : await _saveNew();
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(state.copyWith(status: EditorStatus.saved));
      case Err(failure: ValidationFailure(:final fieldErrors))
          when fieldErrors.isNotEmpty:
        emit(
          state.copyWith(status: EditorStatus.editing, fieldErrors: fieldErrors),
        );
      case Err(:final failure):
        emit(state.copyWith(status: EditorStatus.editing, failure: failure));
    }
  }

  Future<Result<Unit>> _saveNew() async {
    final result = await _createTask(
      TaskDraft(details: _details(), schedule: _schedule(state.date)),
    );
    return result.map((_) => unit);
  }

  Future<Result<Unit>> _saveEdit() async {
    final original = state.original;
    if (original == null) return const Err(Failure.notFound(entity: 'task'));

    final details = _details();
    if (details != _detailsOf(original)) {
      final updated = await _updateTaskDetails(
        UpdateTaskDetailsParams(taskId: original.id, details: details),
      );
      if (updated case Err(:final failure)) return Err(failure);
    }

    final fromDate = state.editsFromDate
        ? (state.editFrom ?? state.today)
        : state.date;
    final schedule = _schedule(fromDate);
    final before = _normalized(original.schedule);
    final unchanged = state.editsFromDate
        ? schedule.copyWith(startDate: before.startDate) == before
        : schedule == before;
    if (unchanged) return const Ok(unit);

    final rescheduled = await _rescheduleTaskFrom(
      RescheduleTaskParams(
        taskId: original.id,
        fromDate: fromDate,
        schedule: schedule,
      ),
    );
    return rescheduled.map((_) => unit);
  }

  TaskDetails _details() {
    final notes = state.notes.trim();
    final reminder = state.reminder;
    return TaskDetails(
      title: state.title.trim(),
      notes: notes.isEmpty ? null : notes,
      categoryId: state.categoryId,
      priority: state.priority,
      plannedDuration: state.duration,
      // A reminder needs a start time.
      reminderOffsets: reminder == null || state.time == null
          ? const []
          : [reminder],
    );
  }

  static TaskDetails _detailsOf(Task task) => TaskDetails(
    title: task.title,
    notes: task.notes,
    categoryId: task.categoryId,
    priority: task.priority,
    plannedDuration: task.plannedDuration,
    reminderOffsets: task.reminderOffsets,
  );

  TaskSchedule _schedule(LocalDate startDate) {
    final frequency = state.frequency;
    final original = state.original?.schedule;
    return TaskSchedule(
      startDate: startDate,
      startTime: state.time,
      timeZone: state.timeZone,
      rule: RecurrenceRule(
        frequency: frequency,
        interval: frequency == RecurrenceFrequency.none ? 1 : state.interval,
        weekdays: frequency == RecurrenceFrequency.weekly
            ? state.weekdays
            : const [],
        // Pinned explicitly so a later split keeps the same day of month.
        monthDay: frequency == RecurrenceFrequency.monthly
            ? _monthDay(original)
            : null,
        until: frequency != RecurrenceFrequency.none &&
                state.repeatEnd == RepeatEnd.onDate
            ? state.until
            : null,
        count: frequency != RecurrenceFrequency.none &&
                state.repeatEnd == RepeatEnd.afterCount
            ? state.count
            : null,
      ),
    );
  }

  /// The form's date sets the day of month, except when a repeating task
  /// is edited from a later date: then the series keeps its day.
  int _monthDay(TaskSchedule? original) {
    if (!state.editsFromDate || original == null) return state.date.day;
    return original.rule.monthDay ?? original.startDate.day;
  }

  @override
  Future<void> close() async {
    await _categories?.cancel();
    await super.close();
  }
}
