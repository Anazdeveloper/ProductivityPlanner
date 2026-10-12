import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/usecases/profile.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/profile/presentation/bloc/profile_cubit.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  ProfileCubit build() => ProfileCubit(
    watchAuthState: WatchAuthState(repository),
    refreshCurrentUser: RefreshCurrentUser(repository),
    updateDisplayName: UpdateDisplayName(repository),
  );

  setUp(() => repository = FakeAuthRepository(
    initial: const AuthState.authenticated(testUser),
  ));

  test('starts with the signed-in user', () {
    expect(build().state.user, testUser);
  });

  blocTest<ProfileCubit, ProfileState>(
    'saving a name updates the user and counts the save',
    build: build,
    act: (cubit) => cubit.saveDisplayName('  Anaz  '),
    wait: Duration.zero,
    verify: (cubit) {
      expect(cubit.state.user?.displayName, 'Anaz');
      expect(cubit.state.savedCount, 1);
      expect(cubit.state.saving, isFalse);
    },
  );

  blocTest<ProfileCubit, ProfileState>(
    'an empty name is rejected locally',
    build: build,
    act: (cubit) => cubit.saveDisplayName('   '),
    verify: (cubit) {
      expect(cubit.state.failure, isA<ValidationFailure>());
      expect(cubit.state.savedCount, 0);
    },
  );
}
