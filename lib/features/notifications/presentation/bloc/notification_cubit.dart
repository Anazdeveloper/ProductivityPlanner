import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/notification_access.dart';

part 'notification_cubit.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    /// Null until first loaded.
    NotificationAccess? access,
    @Default(false) bool busy,

    /// The last failed action; `failureCount` changes with each one so the
    /// page shows it once.
    Failure? failure,
    @Default(0) int failureCount,
  }) = _NotificationState;

  const NotificationState._();

  /// Show the "reminders are off" banner: the user wants reminders but the
  /// OS does not allow them.
  bool get showPermissionBanner {
    final current = access;
    return current != null &&
        current.remindersEnabled &&
        current.permission != NotificationPermission.granted;
  }
}

/// Notification permission and the in-app reminders switch. Holds state
/// only: scheduling is the reminder sync's job, which reacts to the same
/// settings.
final class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required GetNotificationAccess getAccess,
    required RequestNotificationPermission requestPermission,
    required RequestExactAlarms requestExactAlarms,
    required OpenNotificationSettings openSettings,
    required SetRemindersEnabled setRemindersEnabled,
    required WatchRemindersEnabled watchRemindersEnabled,
  }) : _getAccess = getAccess,
       _requestPermission = requestPermission,
       _requestExactAlarms = requestExactAlarms,
       _openSettings = openSettings,
       _setRemindersEnabled = setRemindersEnabled,
       super(const NotificationState()) {
    _enabled = watchRemindersEnabled().listen((_) => refresh());
  }

  final GetNotificationAccess _getAccess;
  final RequestNotificationPermission _requestPermission;
  final RequestExactAlarms _requestExactAlarms;
  final OpenNotificationSettings _openSettings;
  final SetRemindersEnabled _setRemindersEnabled;
  late final StreamSubscription<bool> _enabled;

  /// Re-reads the OS state (call on resume: the user may have changed it in
  /// the system settings).
  Future<void> refresh() async {
    final result = await _getAccess(const NoParams());
    if (isClosed) return;
    if (result case Ok(:final value)) emit(state.copyWith(access: value));
  }

  /// "Turn on": prompts, or opens the system settings if refused before.
  Future<void> turnOn() => _run(() async {
    final enabled = await _setRemindersEnabled(true);
    if (enabled case Err(:final failure)) return Err(failure);
    return await _requestPermission(const NoParams());
  });

  Future<void> allowExactAlarms() =>
      _run(() => _requestExactAlarms(const NoParams()));

  Future<void> openSystemSettings() => _run(() async {
    final opened = await _openSettings(const NoParams());
    if (opened case Err(:final failure)) return Err(failure);
    return await _getAccess(const NoParams());
  });

  Future<void> setRemindersEnabled({required bool enabled}) => _run(() async {
    final saved = await _setRemindersEnabled(enabled);
    if (saved case Err(:final failure)) return Err(failure);
    return await _getAccess(const NoParams());
  });

  Future<void> _run(
    Future<Result<NotificationAccess>> Function() action,
  ) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true));
    final result = await action();
    if (isClosed) return;
    emit(
      switch (result) {
        Ok(:final value) => state.copyWith(busy: false, access: value),
        Err(:final failure) => state.copyWith(
          busy: false,
          failure: failure,
          failureCount: state.failureCount + 1,
        ),
      },
    );
  }

  @override
  Future<void> close() async {
    await _enabled.cancel();
    await super.close();
  }
}
