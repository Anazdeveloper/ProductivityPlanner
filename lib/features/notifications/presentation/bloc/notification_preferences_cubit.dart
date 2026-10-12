import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';
import 'package:productivity_planner/features/notifications/domain/usecases/push.dart';

part 'notification_preferences_cubit.freezed.dart';

enum PreferencesLoad { loading, ready, failure }

@freezed
abstract class NotificationPreferencesState
    with _$NotificationPreferencesState {
  const factory NotificationPreferencesState({
    @Default(PreferencesLoad.loading) PreferencesLoad load,
    @Default(NotificationPreferences()) NotificationPreferences preferences,
    @Default(false) bool saving,
    Failure? failure,
    @Default(0) int failureCount,
  }) = _NotificationPreferencesState;
}

/// Server-side push categories. Changes apply immediately in the UI and
/// roll back if the server rejects them (these need a connection; there is
/// no offline queue for account settings).
final class NotificationPreferencesCubit
    extends Cubit<NotificationPreferencesState> {
  NotificationPreferencesCubit({
    required LoadNotificationPreferences load,
    required SaveNotificationPreferences save,
  }) : _load = load,
       _save = save,
       super(const NotificationPreferencesState());

  final LoadNotificationPreferences _load;
  final SaveNotificationPreferences _save;

  Future<void> load() async {
    if (state.load != PreferencesLoad.loading) {
      emit(state.copyWith(load: PreferencesLoad.loading));
    }
    final result = await _load(const NoParams());
    if (isClosed) return;
    emit(
      switch (result) {
        Ok(:final value) => state.copyWith(
          load: PreferencesLoad.ready,
          preferences: value,
        ),
        Err(:final failure) => state.copyWith(
          load: PreferencesLoad.failure,
          failure: failure,
        ),
      },
    );
  }

  Future<void> setInsights({required bool enabled}) =>
      _update(state.preferences.copyWith(insights: enabled));

  Future<void> setWeeklySummary({required bool enabled}) =>
      _update(state.preferences.copyWith(weeklySummary: enabled));

  Future<void> _update(NotificationPreferences next) async {
    if (state.saving || state.load != PreferencesLoad.ready) return;
    final previous = state.preferences;
    emit(state.copyWith(preferences: next, saving: true));
    final result = await _save(next);
    if (isClosed) return;
    emit(
      switch (result) {
        Ok(:final value) => state.copyWith(saving: false, preferences: value),
        Err(:final failure) => state.copyWith(
          saving: false,
          preferences: previous,
          failure: failure,
          failureCount: state.failureCount + 1,
        ),
      },
    );
  }
}
