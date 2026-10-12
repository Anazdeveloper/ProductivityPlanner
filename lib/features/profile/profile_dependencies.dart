import 'package:get_it/get_it.dart';
import 'package:productivity_planner/features/auth/domain/usecases/profile.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/profile/presentation/bloc/profile_cubit.dart';

/// Profile has no data layer of its own: it uses the auth feature's domain
/// use cases (the session owns the cached profile). Requires auth.
void registerProfileDependencies(GetIt getIt) {
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      watchAuthState: getIt<WatchAuthState>(),
      refreshCurrentUser: getIt<RefreshCurrentUser>(),
      updateDisplayName: getIt<UpdateDisplayName>(),
    ),
  );
}
