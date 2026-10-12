import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/postpone_targets.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/edit_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

part 'task_detail_cubit.freezed.dart';

enum DetailStatus { loading, ready, notFound, failure }

@freezed
abstract class TaskDetailState with _$TaskDetailState {
  const factory TaskDetailState({
    required DateTime now,
    @Default(DetailStatus.loading) DetailStatus status,
    AgendaEntry? entry,

    /// Today in the task's zone (for "Today"/"Tomorrow" labels and pickers).
    LocalDate? today,

    /// Whether "later today" is still possible for this occurrence.
    @Default(false) bool canPostponeLaterToday,
    @Default(false) bool busy,
    Failure? loadFailure,

    /// The last failed action; [actionFailureCount] changes with each one.
    Failure? actionFailure,
    @Default(0) int actionFailureCount,

    /// Set once the series was deleted from this screen (the page closes).
    @Default(false) bool deleted,
  }) = _TaskDetailState;
}

/// One occurrence and what can be done to it: complete (optionally with
/// the time it took), skip, postpone, cancel, reopen, note, and series
/// actions (end repeat, delete). Start/pause/resume, the live timer and
/// timed completion belong to `FocusTimerBloc`, shown on the same page.
final class TaskDetailCubit extends Cubit<TaskDetailState> {
  TaskDetailCubit({
    required this.occurrenceId,
    required WatchAgendaItem watchAgendaItem,
    required ApplyOccurrenceAction applyAction,
    required EndTask endTask,
    required DeleteTask deleteTask,
    required AgendaSummarizer summarizer,
    required PostponeTargets postponeTargets,
    required TimeZoneConverter converter,
    required Clock clock,
    required Ticker ticker,
  }) : _watchAgendaItem = watchAgendaItem,
       _applyAction = applyAction,
       _endTask = endTask,
       _deleteTask = deleteTask,
       _summarizer = summarizer,
       _postponeTargets = postponeTargets,
       _converter = converter,
       _clock = clock,
       _ticker = ticker,
       super(TaskDetailState(now: clock.now()));

  /// The "later today" quick choice.
  static const laterDelay = Duration(hours: 1);

  final String occurrenceId;
  final WatchAgendaItem _watchAgendaItem;
  final ApplyOccurrenceAction _applyAction;
  final EndTask _endTask;
  final DeleteTask _deleteTask;
  final AgendaSummarizer _summarizer;
  final PostponeTargets _postponeTargets;
  final TimeZoneConverter _converter;
  final Clock _clock;
  final Ticker _ticker;

  StreamSubscription<Result<AgendaItem?>>? _item;
  StreamSubscription<DateTime>? _ticks;
  AgendaItem? _current;

  /// Whether the database has answered at least once (before that, a
  /// missing item is "loading", not "not found").
  bool _received = false;

  void start() {
    _item ??= _watchAgendaItem(occurrenceId).listen((result) {
      switch (result) {
        case Ok(:final value):
          _current = value;
          _received = true;
          _rebuild(_clock.now());
        case Err(:final failure):
          emit(
            state.copyWith(status: DetailStatus.failure, loadFailure: failure),
          );
      }
    });
    _ticks ??= _ticker.ticks().listen(_rebuild);
  }

  void _rebuild(DateTime now) {
    final item = _current;
    if (item == null) {
      emit(
        state.copyWith(
          now: now,
          status: _received ? DetailStatus.notFound : state.status,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        now: now,
        status: DetailStatus.ready,
        entry: _summarizer.entries([item], now).first,
        today: _zoneToday(item.task.schedule.timeZone, now),
        canPostponeLaterToday:
            _postponeTargets.later(item, now, laterDelay) != null,
      ),
    );
  }

  LocalDate _zoneToday(String zone, DateTime now) => _converter.localDate(
    now,
    _converter.isValidZone(zone) ? zone : 'UTC',
  );

  // Occurrence actions

  Future<void> complete({Duration? actualDuration}) =>
      _apply(CompleteOccurrence(actualDuration: actualDuration));

  Future<void> skip(SkipReason reason) => _apply(SkipOccurrence(reason));

  Future<void> cancelOccurrence() => _apply(const CancelOccurrence());

  Future<void> reopen() => _apply(const ReopenOccurrence());

  Future<void> saveNote(String? note) => _apply(UpdateOccurrenceNote(note));

  Future<void> postponeLaterToday() async {
    final item = _current;
    if (item == null) return;
    final action = _postponeTargets.later(item, _clock.now(), laterDelay);
    if (action != null) await _apply(action);
  }

  Future<void> postponeTomorrow() async {
    final item = _current;
    if (item == null) return;
    await _apply(_postponeTargets.tomorrow(item, _clock.now()));
  }

  Future<void> postponeTo(LocalDate date, LocalTime? time) =>
      _apply(PostponeOccurrence(toDate: date, toTime: time));

  Future<void> _apply(OccurrenceAction action) => _guard(
    () => _applyAction(
      OccurrenceActionParams(occurrenceId: occurrenceId, action: action),
    ),
  );

  // Series actions

  /// Stops the task from repeating after today.
  Future<void> endRepeat() async {
    final taskId = _current?.task.id;
    if (taskId == null) return;
    await _guard(() => _endTask(EndTaskParams(taskId: taskId)));
  }

  Future<void> deleteTask() async {
    final taskId = _current?.task.id;
    if (taskId == null) return;
    final ok = await _guard(() => _deleteTask(taskId));
    if (ok && !isClosed) emit(state.copyWith(deleted: true));
  }

  /// Runs [action] with `busy` set; reports a failure once. Returns whether
  /// it succeeded.
  Future<bool> _guard<T>(Future<Result<T>> Function() action) async {
    if (state.busy) return false;
    emit(state.copyWith(busy: true));
    final result = await action();
    if (isClosed) return false;
    switch (result) {
      case Ok():
        emit(state.copyWith(busy: false));
        return true;
      case Err(:final failure):
        emit(
          state.copyWith(
            busy: false,
            actionFailure: failure,
            actionFailureCount: state.actionFailureCount + 1,
          ),
        );
        return false;
    }
  }

  @override
  Future<void> close() async {
    await _item?.cancel();
    await _ticks?.cancel();
    await super.close();
  }
}
