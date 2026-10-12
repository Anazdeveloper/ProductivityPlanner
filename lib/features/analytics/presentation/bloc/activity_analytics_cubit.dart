import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';
import 'package:productivity_planner/features/analytics/domain/entities/productivity_metrics.dart';
import 'package:productivity_planner/features/analytics/domain/services/analytics_calculator.dart';
import 'package:productivity_planner/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

part 'activity_analytics_cubit.freezed.dart';

enum ActivityLoad { loading, ready, notFound, failure }

@freezed
abstract class ActivityAnalyticsState with _$ActivityAnalyticsState {
  const factory ActivityAnalyticsState({
    @Default(ActivityLoad.loading) ActivityLoad load,
    ActivityStats? stats,

    /// The first date the stats cover.
    LocalDate? from,
    @Default(AnalyticsAccess(suggestionsUnlocked: true)) AnalyticsAccess access,
    @Default(false) bool applying,

    /// Changes each time a suggestion was applied (for a confirmation).
    @Default(0) int appliedCount,
    Failure? loadFailure,
    Failure? failure,
    @Default(0) int failureCount,
  }) = _ActivityAnalyticsState;

  const ActivityAnalyticsState._();

  /// The suggestion to offer, if the plan includes it.
  DurationSuggestion? get suggestion =>
      access.suggestionsUnlocked ? stats?.suggestion : null;

  /// There is a suggestion, but the plan does not include it.
  bool get suggestionLocked =>
      !access.suggestionsUnlocked && stats?.suggestion != null;
}

/// Task-specific analytics: one activity (lineage) over the last 90 days,
/// with streaks, plan-vs-actual history and a learned duration.
final class ActivityAnalyticsCubit extends Cubit<ActivityAnalyticsState> {
  ActivityAnalyticsCubit({
    required this.lineageId,
    required WatchActivityRecords watchActivityRecords,
    required GetHomeToday getHomeToday,
    required GetAnalyticsAccess getAccess,
    required ApplyDurationSuggestion applySuggestion,
    required AnalyticsCalculator calculator,
    required Clock clock,
  }) : _watchActivityRecords = watchActivityRecords,
       _getHomeToday = getHomeToday,
       _getAccess = getAccess,
       _applySuggestion = applySuggestion,
       _calculator = calculator,
       _clock = clock,
       super(const ActivityAnalyticsState());

  /// Days of history the screen covers (within the plan's window).
  static const windowDays = 90;

  /// Days after today that are read only to find the series carrying the
  /// current schedule (a schedule change can start in the future).
  static const lookAheadDays = 31;

  final String lineageId;
  final WatchActivityRecords _watchActivityRecords;
  final GetHomeToday _getHomeToday;
  final GetAnalyticsAccess _getAccess;
  final ApplyDurationSuggestion _applySuggestion;
  final AnalyticsCalculator _calculator;
  final Clock _clock;

  StreamSubscription<Result<List<ExecutionRecord>>>? _records;
  StreamSubscription<void>? _plan;

  /// Call once.
  void start() => unawaited(_start());

  Future<void> _start() async {
    final today =
        (await _getHomeToday(const NoParams())).valueOrNull ??
        LocalDate.fromDateTime(_clock.now());
    final access = (await _getAccess(today)).valueOrNull ?? state.access;
    if (isClosed) return;
    // A plan change re-reads access and, if the history window changed,
    // the records (an upgrade widens the window the suggestion uses).
    _plan ??= _getAccess.changes.listen(
      (_) => unawaited(_refreshAccess(today)),
    );
    _apply(access, today);
  }

  /// Uses [access]: its window decides the first date read.
  void _apply(AnalyticsAccess access, LocalDate today) {
    final window = today.addDays(-(windowDays - 1));
    final earliest = access.earliestDate;
    final from = earliest != null && earliest > window ? earliest : window;
    final windowChanged = from != state.from || _records == null;
    emit(state.copyWith(access: access, from: from));
    if (windowChanged) _subscribe(from, today);
  }

  void _subscribe(LocalDate from, LocalDate today) {
    unawaited(_records?.cancel());
    _records =
        _watchActivityRecords(
          ActivityWindow(
            lineageId: lineageId,
            from: from,
            to: today.addDays(lookAheadDays),
          ),
        ).listen((result) {
          if (isClosed || state.from != from) return;
          switch (result) {
            case Ok(:final value):
              final stats = _calculator.activity(
                lineageId,
                value,
                _clock.now(),
              );
              emit(
                state.copyWith(
                  load: stats == null
                      ? ActivityLoad.notFound
                      : ActivityLoad.ready,
                  stats: stats,
                  loadFailure: null,
                ),
              );
            case Err(:final failure):
              emit(
                state.copyWith(
                  load: ActivityLoad.failure,
                  loadFailure: failure,
                ),
              );
          }
        });
  }

  Future<void> _refreshAccess(LocalDate today) async {
    final updated = (await _getAccess(today)).valueOrNull;
    if (updated != null && !isClosed) _apply(updated, today);
  }

  /// Makes the suggested duration the task's expected duration.
  Future<void> applySuggestion() async {
    final stats = state.stats;
    final suggestion = state.suggestion;
    if (stats == null || suggestion == null || state.applying) return;
    emit(state.copyWith(applying: true));
    final result = await _applySuggestion(
      ApplyDurationParams(
        taskId: stats.currentTaskId,
        duration: suggestion.suggested,
      ),
    );
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            applying: false,
            appliedCount: state.appliedCount + 1,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            applying: false,
            failure: failure,
            failureCount: state.failureCount + 1,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _records?.cancel();
    await _plan?.cancel();
    await super.close();
  }
}
