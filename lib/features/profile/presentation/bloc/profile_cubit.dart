import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/user.dart';
import 'package:productivity_planner/features/auth/domain/usecases/profile.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';

part 'profile_cubit.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    User? user,
    @Default(false) bool saving,

    /// Increments after each successful save so the page can confirm once.
    @Default(0) int savedCount,
    Failure? failure,
  }) = _ProfileState;
}

/// Shows the signed-in account and edits the display name. Uses the auth
/// feature's domain only (allowed cross-feature dependency).
final class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required WatchAuthState watchAuthState,
    required RefreshCurrentUser refreshCurrentUser,
    required UpdateDisplayName updateDisplayName,
  }) : _refreshCurrentUser = refreshCurrentUser,
       _updateDisplayName = updateDisplayName,
       super(ProfileState(user: _userOf(watchAuthState.current))) {
    _subscription = watchAuthState().listen((auth) {
      emit(state.copyWith(user: _userOf(auth)));
    });
  }

  final RefreshCurrentUser _refreshCurrentUser;
  final UpdateDisplayName _updateDisplayName;
  late final StreamSubscription<AuthState> _subscription;

  /// Pulls the latest profile. Silent on failure: the cached profile stays.
  Future<void> refresh() async {
    await _refreshCurrentUser(const NoParams());
  }

  Future<void> saveDisplayName(String value) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, failure: null));
    final result = await _updateDisplayName(value);
    if (isClosed) return;
    emit(
      state.copyWith(
        saving: false,
        failure: result.failureOrNull,
        savedCount: result.isOk ? state.savedCount + 1 : state.savedCount,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }

  static User? _userOf(AuthState state) => switch (state) {
    Authenticated(:final user) => user,
    _ => null,
  };
}
