import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

part 'focus_timer_bloc.freezed.dart';

/// Which occurrence a timer follows.
sealed class FocusTarget {
  const FocusTarget();
}

/// Whatever the person is working on (Today's "Now" card).
final class ActiveWorkTarget extends FocusTarget {
  const ActiveWorkTarget();
}

/// One occurrence (the detail screen).
final class OccurrenceTarget extends FocusTarget {
  const OccurrenceTarget(this.occurrenceId);

  final String occurrenceId;
}

// Events

sealed class FocusTimerEvent {
  const FocusTimerEvent();
}

/// Starts following the target. Sent once by the route.
final class FocusTimerSubscribed extends FocusTimerEvent {
  const FocusTimerSubscribed();
}

/// Start (or resume) work. [occurrenceId] defaults to the followed
/// occurrence; Today passes the next task's id.
final class FocusTimerStartPressed extends FocusTimerEvent {
  const FocusTimerStartPressed({this.occurrenceId});

  final String? occurrenceId;
}

final class FocusTimerPausePressed extends FocusTimerEvent {
  const FocusTimerPausePressed();
}

/// Done, with the tracked time. Asks first when that time is implausible.
final class FocusTimerCompletePressed extends FocusTimerEvent {
  const FocusTimerCompletePressed();
}

/// The answer to the "long session" question: keep the tracked time
/// (`actualDuration` null) or use the time the person entered.
final class FocusTimerCompleteConfirmed extends FocusTimerEvent {
  const FocusTimerCompleteConfirmed({this.actualDuration});

  final Duration? actualDuration;
}

final class FocusTimerConfirmationDismissed extends FocusTimerEvent {
  const FocusTimerConfirmationDismissed();
}

final class _ItemReceived extends FocusTimerEvent {
  const _ItemReceived(this.result);

  final Result<AgendaItem?> result;
}

final class _Ticked extends FocusTimerEvent {
  const _Ticked(this.now);

  final DateTime now;
}

// State

enum FocusLoad { loading, ready, failure }

@freezed
abstract class FocusTimerState with _$FocusTimerState {
  const factory FocusTimerState({
    @Default(FocusLoad.loading) FocusLoad load,

    /// The followed occurrence; null when there is none (nothing in
    /// progress, or the occurrence was deleted).
    AgendaItem? item,

    /// Null until the occurrence has been started at least once.
    TimerSnapshot? timer,
    @Default(false) bool busy,

    /// Set when Done needs confirming; `confirmCount` changes with each
    /// request so the page opens the dialog once.
    Duration? confirmTracked,

    /// The occurrence the open question is about. The answer completes
    /// this one even if the followed item changed meanwhile.
    String? confirmOccurrenceId,
    @Default(0) int confirmCount,

    /// Title of a task that was paused because this one started;
    /// `noticeCount` changes with each.
    String? autoPausedTitle,
    @Default(0) int noticeCount,
    Failure? loadFailure,
    Failure? failure,
    @Default(0) int failureCount,
  }) = _FocusTimerState;

  const FocusTimerState._();

  bool get running => timer?.running ?? false;
}

/// Start, pause, resume and complete with a live elapsed time.
///
/// A Bloc rather than a Cubit because three kinds of input interleave and
/// their order matters: database changes (another device, a notification
/// button, the agenda), clock ticks, and the person's commands.
///
/// Time is never counted here: every tick recomputes the snapshot from the
/// persisted sessions and the clock, and ticks run only while a session
/// is open.
final class FocusTimerBloc extends Bloc<FocusTimerEvent, FocusTimerState> {
  FocusTimerBloc({
    required this.target,
    required WatchActiveWork watchActiveWork,
    required WatchAgendaItem watchAgendaItem,
    required ApplyOccurrenceAction applyAction,
    required WorkTimer workTimer,
    required Clock clock,
    required Ticker ticker,
  }) : _watchActiveWork = watchActiveWork,
       _watchAgendaItem = watchAgendaItem,
       _applyAction = applyAction,
       _workTimer = workTimer,
       _clock = clock,
       _ticker = ticker,
       super(const FocusTimerState()) {
    on<FocusTimerSubscribed>(_onSubscribed);
    on<_ItemReceived>(_onItem);
    on<_Ticked>(_onTick);
    on<FocusTimerStartPressed>(_onStart);
    on<FocusTimerPausePressed>(_onPause);
    on<FocusTimerCompletePressed>(_onComplete);
    on<FocusTimerCompleteConfirmed>(_onConfirmed);
    on<FocusTimerConfirmationDismissed>(
      (_, emit) => emit(
        state.copyWith(confirmTracked: null, confirmOccurrenceId: null),
      ),
    );
  }

  final FocusTarget target;
  final WatchActiveWork _watchActiveWork;
  final WatchAgendaItem _watchAgendaItem;
  final ApplyOccurrenceAction _applyAction;
  final WorkTimer _workTimer;
  final Clock _clock;

  /// One-second ticks (the timer shows seconds).
  final Ticker _ticker;

  StreamSubscription<Result<AgendaItem?>>? _source;
  StreamSubscription<DateTime>? _ticks;

  void _onSubscribed(FocusTimerSubscribed event, Emitter<FocusTimerState> _) {
    final stream = switch (target) {
      ActiveWorkTarget() => _watchActiveWork(const NoParams()),
      OccurrenceTarget(:final occurrenceId) => _watchAgendaItem(occurrenceId),
    };
    _source ??= stream.listen((result) => add(_ItemReceived(result)));
  }

  void _onItem(_ItemReceived event, Emitter<FocusTimerState> emit) {
    switch (event.result) {
      case Ok(:final value):
        final timer = value == null
            ? null
            : _workTimer.snapshot(value, _clock.now());
        emit(
          state.copyWith(
            load: FocusLoad.ready,
            item: value,
            timer: timer,
            loadFailure: null,
          ),
        );
        _setTicking(on: timer?.running ?? false);
      case Err(:final failure):
        emit(state.copyWith(load: FocusLoad.failure, loadFailure: failure));
        _setTicking(on: false);
    }
  }

  void _onTick(_Ticked event, Emitter<FocusTimerState> emit) {
    final item = state.item;
    if (item == null) return;
    emit(state.copyWith(timer: _workTimer.snapshot(item, event.now)));
  }

  void _setTicking({required bool on}) {
    if (on) {
      _ticks ??= _ticker.ticks().listen((now) => add(_Ticked(now)));
    } else {
      unawaited(_ticks?.cancel());
      _ticks = null;
    }
  }

  Future<void> _onStart(
    FocusTimerStartPressed event,
    Emitter<FocusTimerState> emit,
  ) async {
    final id = event.occurrenceId ?? state.item?.occurrence.id;
    if (id == null) return;
    final outcome = await _run(emit, id, const StartOccurrence());
    final paused = outcome?.autoPausedSession;
    if (paused == null || isClosed) return;
    // Name the task that was paused, so switching is never silent.
    final other = await _watchAgendaItem(paused.occurrenceId).first;
    final title = other.valueOrNull?.task.title;
    if (title != null && !isClosed) {
      emit(
        state.copyWith(
          autoPausedTitle: title,
          noticeCount: state.noticeCount + 1,
        ),
      );
    }
  }

  Future<void> _onPause(
    FocusTimerPausePressed event,
    Emitter<FocusTimerState> emit,
  ) async {
    final id = state.item?.occurrence.id;
    if (id == null) return;
    await _run(emit, id, const PauseOccurrence());
  }

  Future<void> _onComplete(
    FocusTimerCompletePressed event,
    Emitter<FocusTimerState> emit,
  ) async {
    final item = state.item;
    if (item == null || state.busy) return;
    final tracked = _workTimer.snapshot(item, _clock.now())?.tracked;
    if (tracked != null &&
        _workTimer.isImplausible(tracked, item.occurrence.plannedDuration)) {
      emit(
        state.copyWith(
          confirmTracked: tracked,
          confirmOccurrenceId: item.occurrence.id,
          confirmCount: state.confirmCount + 1,
        ),
      );
      return;
    }
    await _run(emit, item.occurrence.id, const CompleteOccurrence());
  }

  Future<void> _onConfirmed(
    FocusTimerCompleteConfirmed event,
    Emitter<FocusTimerState> emit,
  ) async {
    final id = state.confirmOccurrenceId;
    emit(state.copyWith(confirmTracked: null, confirmOccurrenceId: null));
    if (id == null) return;
    await _run(
      emit,
      id,
      CompleteOccurrence(actualDuration: event.actualDuration),
    );
  }

  /// Applies [action] with `busy` set; a failure is reported once.
  Future<LifecycleOutcome?> _run(
    Emitter<FocusTimerState> emit,
    String occurrenceId,
    OccurrenceAction action,
  ) async {
    if (state.busy) return null;
    emit(state.copyWith(busy: true));
    final result = await _applyAction(
      OccurrenceActionParams(occurrenceId: occurrenceId, action: action),
    );
    if (isClosed) return null;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(busy: false));
        return value;
      case Err(:final failure):
        emit(
          state.copyWith(
            busy: false,
            failure: failure,
            failureCount: state.failureCount + 1,
          ),
        );
        return null;
    }
  }

  @override
  Future<void> close() async {
    await _source?.cancel();
    await _ticks?.cancel();
    await super.close();
  }
}
