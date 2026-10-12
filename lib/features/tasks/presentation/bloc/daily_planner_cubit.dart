import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_draft.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/create_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

part 'daily_planner_cubit.freezed.dart';

/// Today shows one day; Planner shows the week around the selected day.
enum PlannerScope { day, week }

enum PlannerLoad { loading, ready, failure }

@freezed
abstract class DailyPlannerState with _$DailyPlannerState {
  const factory DailyPlannerState({
    /// Today in the user's home zone.
    required LocalDate today,
    required LocalDate selectedDay,

    /// The loaded range: the selected day, or its Monday–Sunday week.
    required LocalDate rangeStart,
    required LocalDate rangeEnd,
    required DateTime now,
    @Default(PlannerLoad.loading) PlannerLoad load,

    /// The selected day's entries in agenda order.
    @Default(<AgendaEntry>[]) List<AgendaEntry> dayEntries,
    @Default(DaySummary.empty) DaySummary summary,

    /// Per-day summaries for the loaded range (week strip).
    @Default(<LocalDate, DaySummary>{}) Map<LocalDate, DaySummary> rangeSummaries,
    Failure? loadFailure,

    /// The last failed action; [actionFailureCount] changes with each one so
    /// the page can show it exactly once.
    Failure? actionFailure,
    @Default(0) int actionFailureCount,

    /// Occurrences with an action in flight (their controls are disabled).
    @Default(<String>{}) Set<String> busy,
  }) = _DailyPlannerState;

  const DailyPlannerState._();

  bool get isToday => selectedDay == today;
}

/// Drives Today and Planner: the agenda for a day (or week), live from the
/// local database, with statuses that follow the clock and the day
/// rolling over at midnight.
final class DailyPlannerCubit extends Cubit<DailyPlannerState> {
  DailyPlannerCubit({
    required this.scope,
    required WatchAgenda watchAgenda,
    required GetHomeToday getHomeToday,
    required GetHomeTimeZone getHomeTimeZone,
    required ApplyOccurrenceAction applyAction,
    required CreateTask createTask,
    required AgendaSummarizer summarizer,
    required Clock clock,
    required Ticker ticker,
  }) : _watchAgenda = watchAgenda,
       _getHomeToday = getHomeToday,
       _getHomeTimeZone = getHomeTimeZone,
       _applyAction = applyAction,
       _createTask = createTask,
       _summarizer = summarizer,
       _clock = clock,
       _ticker = ticker,
       super(_initialState(clock.now()));

  /// Quick-added tasks get this duration; the user can edit it later.
  static const quickAddDuration = Duration(minutes: 30);

  final PlannerScope scope;
  final WatchAgenda _watchAgenda;
  final GetHomeToday _getHomeToday;
  final GetHomeTimeZone _getHomeTimeZone;
  final ApplyOccurrenceAction _applyAction;
  final CreateTask _createTask;
  final AgendaSummarizer _summarizer;
  final Clock _clock;
  final Ticker _ticker;

  StreamSubscription<Result<List<AgendaItem>>>? _agenda;
  StreamSubscription<DateTime>? _ticks;
  List<AgendaItem> _items = const [];

  /// Whether the current range has delivered data at least once.
  bool _loaded = false;

  /// Whether the selection moves along when the day rolls over.
  bool _followingToday = true;

  static DailyPlannerState _initialState(DateTime now) {
    // Placeholder until the home zone is known (milliseconds later).
    final day = LocalDate.fromDateTime(now);
    return DailyPlannerState(
      today: day,
      selectedDay: day,
      rangeStart: day,
      rangeEnd: day,
      now: now,
    );
  }

  /// Loads today and starts listening. Call once after creation.
  void start({LocalDate? initialDay}) => unawaited(_start(initialDay));

  Future<void> _start(LocalDate? initialDay) async {
    final today = await _homeToday();
    if (isClosed) return;
    final selected = initialDay ?? today;
    _followingToday = selected == today;
    emit(state.copyWith(today: today));
    _show(selected);
    _ticks ??= _ticker.ticks().listen(_onTick);
  }

  void selectDay(LocalDate day) {
    _followingToday = day == state.today;
    _show(day);
  }

  void goToToday() => selectDay(state.today);

  void nextWeek() => selectDay(state.selectedDay.addDays(7));

  void previousWeek() => selectDay(state.selectedDay.addDays(-7));

  /// Marks done, or reopens if already done.
  Future<void> toggleComplete(String occurrenceId) async {
    final entry = _entryById(occurrenceId);
    if (entry == null || state.busy.contains(occurrenceId)) return;
    await _run(
      occurrenceId,
      entry.isDone ? const ReopenOccurrence() : const CompleteOccurrence(),
    );
  }

  /// Creates a one-off, any-time task on the selected day (today if the
  /// selected day is past). Returns whether it was created, so the field
  /// can be cleared.
  Future<bool> quickAdd(String title) async {
    if (title.trim().isEmpty) return false;
    final zone = (await _getHomeTimeZone(const NoParams())).valueOrNull;
    final date = maxDate(state.selectedDay, state.today);
    final result = await _createTask(
      TaskDraft(
        details: TaskDetails(
          title: title,
          plannedDuration: quickAddDuration,
          reminderOffsets: const [],
        ),
        schedule: TaskSchedule(startDate: date, timeZone: zone ?? 'UTC'),
      ),
    );
    if (isClosed) return false;
    if (result case Err(:final failure)) {
      _reportActionFailure(failure);
      return false;
    }
    return true;
  }

  Future<void> _run(String occurrenceId, OccurrenceAction action) async {
    emit(state.copyWith(busy: {...state.busy, occurrenceId}));
    final result = await _applyAction(
      OccurrenceActionParams(occurrenceId: occurrenceId, action: action),
    );
    if (isClosed) return;
    emit(state.copyWith(busy: {...state.busy}..remove(occurrenceId)));
    if (result case Err(:final failure)) _reportActionFailure(failure);
  }

  void _reportActionFailure(Failure failure) => emit(
    state.copyWith(
      actionFailure: failure,
      actionFailureCount: state.actionFailureCount + 1,
    ),
  );

  AgendaEntry? _entryById(String occurrenceId) {
    for (final entry in state.dayEntries) {
      if (entry.occurrenceId == occurrenceId) return entry;
    }
    return null;
  }

  Future<LocalDate> _homeToday() async =>
      (await _getHomeToday(const NoParams())).valueOrNull ??
      LocalDate.fromDateTime(_clock.now());

  /// Selects [day], (re)subscribing only when the range changes.
  void _show(LocalDate day) {
    final start = scope == PlannerScope.day ? day : day.startOfIsoWeek;
    final end = scope == PlannerScope.day ? day : start.addDays(6);
    final sameRange =
        _agenda != null && start == state.rangeStart && end == state.rangeEnd;
    if (sameRange) {
      emit(state.copyWith(selectedDay: day));
      if (_loaded) _rebuild();
      return;
    }

    unawaited(_agenda?.cancel());
    _items = const [];
    _loaded = false;
    emit(
      state.copyWith(
        selectedDay: day,
        rangeStart: start,
        rangeEnd: end,
        load: PlannerLoad.loading,
        loadFailure: null,
        dayEntries: const [],
        summary: DaySummary.empty,
        rangeSummaries: const {},
      ),
    );
    _agenda = _watchAgenda(
      AgendaRange(from: start, to: end),
    ).listen(_onAgenda);
  }

  void _onAgenda(Result<List<AgendaItem>> result) {
    switch (result) {
      case Ok(:final value):
        _items = value;
        _loaded = true;
        _rebuild();
      case Err(:final failure):
        emit(state.copyWith(load: PlannerLoad.failure, loadFailure: failure));
    }
  }

  Future<void> _onTick(DateTime now) async {
    final today = await _homeToday();
    if (isClosed) return;
    if (today != state.today) {
      emit(state.copyWith(today: today));
      if (_followingToday) {
        _show(today);
        return;
      }
    }
    if (_loaded) {
      _rebuild(now);
    } else {
      emit(state.copyWith(now: now));
    }
  }

  void _rebuild([DateTime? at]) {
    final now = at ?? _clock.now();
    final entries = _summarizer.entries(_items, now);
    final byDay = <LocalDate, List<AgendaEntry>>{};
    for (final entry in entries) {
      (byDay[entry.date] ??= []).add(entry);
    }
    final dayEntries = byDay[state.selectedDay] ?? const <AgendaEntry>[];
    emit(
      state.copyWith(
        now: now,
        load: PlannerLoad.ready,
        loadFailure: null,
        dayEntries: dayEntries,
        summary: _summarizer.summarize(dayEntries),
        rangeSummaries: {
          for (final day in byDay.entries)
            day.key: _summarizer.summarize(day.value),
        },
      ),
    );
  }

  @override
  Future<void> close() async {
    await _agenda?.cancel();
    await _ticks?.cancel();
    await super.close();
  }
}
