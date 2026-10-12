import 'package:get_it/get_it.dart';
import 'package:productivity_planner/config/env/app_environment.dart';
import 'package:productivity_planner/core/device/device_context.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/auth_token_provider.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/auth/data/datasources/account_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/session_storage.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/apple_credential_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/fake_credential_sources.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/google_credential_source.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/nonce_generator.dart';
import 'package:productivity_planner/features/auth/data/datasources/social/social_credentials.dart';
import 'package:productivity_planner/features/auth/data/mock/auth_mock_routes.dart';
import 'package:productivity_planner/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:productivity_planner/features/auth/data/repositories/auth_session_manager.dart';
import 'package:productivity_planner/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity_planner/features/auth/domain/usecases/password_reset.dart';
import 'package:productivity_planner/features/auth/domain/usecases/profile.dart';
import 'package:productivity_planner/features/auth/domain/usecases/register_with_email.dart';
import 'package:productivity_planner/features/auth/domain/usecases/restore_session.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:productivity_planner/features/auth/domain/usecases/sign_out.dart';
import 'package:productivity_planner/features/auth/domain/usecases/social_sign_in.dart';
import 'package:productivity_planner/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/password_reset_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/register_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/sign_in_cubit.dart';

/// Auth feature registrations. Requires core and network registrations.
///
/// Registers [AuthSessionManager] as the app's [AuthTokenProvider], which the
/// authenticated HTTP client depends on.
void registerAuthDependencies(GetIt getIt) {
  final environment = getIt<AppEnvironment>();

  if (environment.useMockApi) {
    AuthMockBackend(
      clock: getIt<Clock>(),
      ids: getIt<IdGenerator>(),
    ).register(getIt<MockApiAdapter>());
  }

  // Data sources
  getIt
    ..registerLazySingleton<SessionStorage>(SecureSessionStorage.new)
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => HttpAuthRemoteDataSource(getIt<PublicHttpClient>()),
    )
    ..registerLazySingleton<AccountRemoteDataSource>(
      () => HttpAccountRemoteDataSource(getIt<ApiHttpClient>()),
    )
    ..registerLazySingleton<NonceGenerator>(NonceGenerator.new)
    ..registerLazySingleton<AppleCredentialSource>(
      () => environment.useMockApi
          ? FakeAppleCredentialSource()
          : const SignInWithAppleCredentialSource(),
    )
    ..registerLazySingleton<GoogleCredentialSource>(
      () => environment.useMockApi
          ? FakeGoogleCredentialSource()
          : GoogleSignInCredentialSource(
              serverClientId: environment.googleServerClientId,
              iosClientId: environment.googleIosClientId,
            ),
    );

  // Session (one instance, two roles)
  getIt
    ..registerLazySingleton<AuthSessionManager>(
      () => AuthSessionManager(
        storage: getIt<SessionStorage>(),
        remote: getIt<AuthRemoteDataSource>(),
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
        reporter: getIt<ErrorReporter>(),
      ),
      dispose: (manager) => manager.dispose(),
    )
    ..registerLazySingleton<AuthTokenProvider>(
      () => getIt<AuthSessionManager>(),
    );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      session: getIt<AuthSessionManager>(),
      authRemote: getIt<AuthRemoteDataSource>(),
      accountRemote: getIt<AccountRemoteDataSource>(),
      apple: getIt<AppleCredentialSource>(),
      google: getIt<GoogleCredentialSource>(),
      nonces: getIt<NonceGenerator>(),
      device: getIt<DeviceContext>(),
      reporter: getIt<ErrorReporter>(),
    ),
  );

  // Use cases (stateless)
  AuthRepository repo() => getIt<AuthRepository>();
  getIt
    ..registerLazySingleton(() => WatchAuthState(repo()))
    ..registerLazySingleton(() => RestoreSession(repo()))
    ..registerLazySingleton(() => SignInWithEmail(repo()))
    ..registerLazySingleton(() => RegisterWithEmail(repo()))
    ..registerLazySingleton(() => SignInWithApple(repo()))
    ..registerLazySingleton(() => SignInWithGoogle(repo()))
    ..registerLazySingleton(() => GetSocialSignInOptions(repo()))
    ..registerLazySingleton(() => RequestPasswordReset(repo()))
    ..registerLazySingleton(() => ResetPassword(repo()))
    ..registerLazySingleton(() => SignOut(repo()))
    ..registerLazySingleton(() => RefreshCurrentUser(repo()))
    ..registerLazySingleton(() => UpdateDisplayName(repo()));

  // Blocs: AuthBloc lives for the whole app; screen cubits are per route.
  getIt
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        watchAuthState: getIt<WatchAuthState>(),
        restoreSession: getIt<RestoreSession>(),
        signOut: getIt<SignOut>(),
      ),
      dispose: (bloc) => bloc.close(),
    )
    ..registerFactory<SignInCubit>(
      () => SignInCubit(
        signInWithEmail: getIt<SignInWithEmail>(),
        signInWithApple: getIt<SignInWithApple>(),
        signInWithGoogle: getIt<SignInWithGoogle>(),
        getSocialSignInOptions: getIt<GetSocialSignInOptions>(),
        watchAuthState: getIt<WatchAuthState>(),
      ),
    )
    ..registerFactory<RegisterCubit>(
      () => RegisterCubit(registerWithEmail: getIt<RegisterWithEmail>()),
    )
    ..registerFactoryParam<PasswordResetCubit, String, void>(
      (initialEmail, _) => PasswordResetCubit(
        requestPasswordReset: getIt<RequestPasswordReset>(),
        resetPassword: getIt<ResetPassword>(),
        initialEmail: initialEmail,
      ),
    );
}
