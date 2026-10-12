import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_issue.dart';
import 'package:productivity_planner/features/sync/domain/entities/sync_status.dart';
import 'package:productivity_planner/features/sync/domain/usecases/sync_usecases.dart';

part 'sync_status_cubit.freezed.dart';

@freezed
abstract class SyncStatusState with _$SyncStatusState {
  const factory SyncStatusState({
    /// Null until the first status arrives.
    SyncStatus? status,
    @Default(<SyncIssue>[]) List<SyncIssue> issues,

    /// A "Sync now" the person asked for is running.
    @Default(false) bool manualSync,

    /// The last failure of an action here; [failureCount] changes with
    /// each one.
    Failure? failure,
    @Default(0) int failureCount,

    /// Changes when a manual sync finished cleanly.
    @Default(0) int syncedCount,
  }) = _SyncStatusState;

  const SyncStatusState._();

  bool get syncing => manualSync || (status?.syncing ?? false);
}

/// The sync status tile and page. A Cubit: plain commands, live data.
final class SyncStatusCubit extends Cubit<SyncStatusState> {
  SyncStatusCubit({
    required WatchSyncStatus watchStatus,
    required WatchSyncIssues watchIssues,
    required SyncNow syncNow,
    required DismissSyncIssue dismissIssue,
    required DismissAllSyncIssues dismissAll,
  }) : _watchStatus = watchStatus,
       _watchIssues = watchIssues,
       _syncNow = syncNow,
       _dismissIssue = dismissIssue,
       _dismissAll = dismissAll,
       super(const SyncStatusState());

  final WatchSyncStatus _watchStatus;
  final WatchSyncIssues _watchIssues;
  final SyncNow _syncNow;
  final DismissSyncIssue _dismissIssue;
  final DismissAllSyncIssues _dismissAll;

  StreamSubscription<SyncStatus>? _status;
  StreamSubscription<Result<List<SyncIssue>>>? _issues;

  /// Call once.
  void start() {
    _status ??= _watchStatus().listen(
      (value) => emit(state.copyWith(status: value)),
    );
    _issues ??= _watchIssues(const NoParams()).listen((result) {
      // A failed read keeps the last list; the store reports the error.
      if (result case Ok(:final value)) emit(state.copyWith(issues: value));
    });
  }

  Future<void> syncNow() async {
    if (state.manualSync) return;
    emit(state.copyWith(manualSync: true));
    final result = await _syncNow(const NoParams());
    if (isClosed) return;
    switch (result) {
      case Ok():
        emit(
          state.copyWith(
            manualSync: false,
            syncedCount: state.syncedCount + 1,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            manualSync: false,
            failure: failure,
            failureCount: state.failureCount + 1,
          ),
        );
    }
  }

  Future<void> dismiss(String issueId) async =>
      _report(await _dismissIssue(issueId));

  Future<void> dismissAll() async =>
      _report(await _dismissAll(const NoParams()));

  void _report(Result<Unit> result) {
    if (isClosed) return;
    if (result case Err(:final failure)) {
      emit(
        state.copyWith(failure: failure, failureCount: state.failureCount + 1),
      );
    }
  }

  @override
  Future<void> close() async {
    await _status?.cancel();
    await _issues?.cancel();
    await super.close();
  }
}
