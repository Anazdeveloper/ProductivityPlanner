import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/analytics/domain/entities/analytics_period.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/domain/services/analytics_calculator.dart';
import 'package:productivity_planner/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

part 'analytics_cubit.freezed.dart';

enum AnalyticsLoad { loading, ready, failure }

@freezed
abstract class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    /// Today in the user's home zone.
    required LocalDate today,
    required AnalyticsPeriod period,
    @Default(AnalyticsLoad.loading) AnalyticsLoad load,

    /// Null until the period's records first arrive.
    AnalyticsReport? report,
    @Default(AnalyticsAccess(suggestionsUnlocked: true)) AnalyticsAccess access,
    Failure? loadFailure,
  }) = _AnalyticsState;

  const AnalyticsState._();

  /// Analytics are about what happened: no periods after today's.
  bool get canGoNext => period.end < today;

  bool get canGoBack => access.allows(period.start.addDays(-1));

  /// Going back is blocked by the plan's history window, not by data.
  bool get historyLimited => !canGoBack && access.earliestDate != null;

  bool get isCurrent => period.contains(today);
}

/// Day, week and month analytics, live from the local history.
///
/// A Cubit: its inputs are plain commands (pick a period, move back or
/// forward) and data/clock updates with no ordering subtleties.
final class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({
    required WatchPeriodRecords watchPeriodRecords,
    required GetHomeToday getHomeToday,
    required GetAnalyticsAccess getAccess,
    required AnalyticsCalculator calculator,
    required Clock clock,
    required Ticker ticker,
  }) : _watchPeriodRecords = watchPeriodRecords,
       _getHomeToday = getHomeToday,
       _getAccess = getAccess,
       _calculator = calculator,
       _clock = clock,
       _ticker = ticker,
       super(_initialState(clock.now()));

  final WatchPeriodRecords _watchPeriodRecords;
  final GetHomeToday _getHomeToday;
  final GetAnalyticsAccess _getAccess;
  final AnalyticsCalculator _calculator;
  final Clock _clock;
  final Ticker _ticker;

  StreamSubscription<Result<List<ExecutionRecord>>>? _records;
  StreamSubscription<DateTime>? _ticks;
  StreamSubscription<void>? _plan;
  List<ExecutionRecord>? _latest;

  static AnalyticsState _initialState(DateTime now) {
    // Placeholder until the home zone is known (milliseconds later).
    final day = LocalDate.fromDateTime(now);
    return AnalyticsState(
      today: day,
      period: AnalyticsPeriod.containing(PeriodKind.week, day),
    );
  }

  /// Loads this week. Call once.
  void start() => unawaited(_start());

  Future<void> _start() async {
    final today = await _refreshToday();
    if (isClosed) return;
    _watch(AnalyticsPeriod.containing(state.period.kind, today));
    _ticks ??= _ticker.ticks().listen((_) => unawaited(_onTick()));
    // An upgrade (or expiry) changes how far back history goes.
    _plan ??= _getAccess.changes.listen((_) => unawaited(_onTick()));
  }

  void selectKind(PeriodKind kind) {
    if (kind == state.period.kind) return;
    _watch(state.period.withKind(kind, around: state.today));
  }

  void previous() {
    if (state.canGoBack) _watch(state.period.previous);
  }

  void next() {
    if (state.canGoNext) _watch(state.period.next);
  }

  /// Back to the period containing today.
  void current() => _watch(
    AnalyticsPeriod.containing(state.period.kind, state.today),
  );

  /// Opens one day of the current week or month (a tapped bar).
  void showDay(LocalDate date) {
    if (date > state.today || !state.access.allows(date)) return;
    _watch(AnalyticsPeriod.containing(PeriodKind.day, date));
  }

  void retry() => _watch(state.period);

  void _watch(AnalyticsPeriod period) {
    unawaited(_records?.cancel());
    _latest = null;
    emit(
      state.copyWith(
        period: period,
        load: AnalyticsLoad.loading,
        report: null,
        loadFailure: null,
      ),
    );
    _records = _watchPeriodRecords(period).listen((result) {
      if (isClosed || state.period != period) return;
      switch (result) {
        case Ok(:final value):
          _latest = value;
          _recompute();
        case Err(:final failure):
          emit(
            state.copyWith(load: AnalyticsLoad.failure, loadFailure: failure),
          );
      }
    });
  }

  void _recompute() {
    final records = _latest;
    if (records == null) return;
    emit(
      state.copyWith(
        load: AnalyticsLoad.ready,
        loadFailure: null,
        report: _calculator.report(state.period, records, _clock.now()),
      ),
    );
  }

  Future<LocalDate> _refreshToday() async {
    final today = (await _getHomeToday(const NoParams())).valueOrNull ??
        state.today;
    final access = (await _getAccess(today)).valueOrNull ?? state.access;
    if (!isClosed) emit(state.copyWith(today: today, access: access));
    return today;
  }

  /// Statuses depend on the clock ("missed" once a day ends), and the day
  /// rolls over at midnight.
  Future<void> _onTick() async {
    final before = state.today;
    final today = await _refreshToday();
    if (isClosed) return;
    final outsideWindow = !state.access.allows(state.period.end);
    if (outsideWindow ||
        (today != before &&
            state.period.contains(before) &&
            !state.period.contains(today))) {
      // Follow the present when the person was looking at it, or when the
      // plan no longer includes the period shown (a downgrade).
      _watch(AnalyticsPeriod.containing(state.period.kind, today));
    } else {
      _recompute();
    }
  }

  @override
  Future<void> close() async {
    await _records?.cancel();
    await _ticks?.cancel();
    await _plan?.cancel();
    await super.close();
  }
}
