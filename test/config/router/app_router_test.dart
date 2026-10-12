import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/app.dart';
import 'package:productivity_planner/config/router/app_router.dart';
import 'package:productivity_planner/config/router/auth_bloc_auth_gate.dart';
import 'package:productivity_planner/features/analytics/presentation/pages/analytics_page.dart';
import 'package:productivity_planner/features/auth/domain/entities/auth_state.dart';
import 'package:productivity_planner/features/auth/domain/entities/social_sign_in_options.dart';
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
import 'package:productivity_planner/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:productivity_planner/features/auth/presentation/pages/register_page.dart';
import 'package:productivity_planner/features/auth/presentation/pages/sign_in_page.dart';
import 'package:productivity_planner/features/auth/presentation/widgets/social_sign_in_buttons.dart';
import 'package:productivity_planner/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:productivity_planner/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:productivity_planner/features/profile/presentation/pages/profile_page.dart';
import 'package:productivity_planner/features/sync/presentation/pages/sync_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/occurrence_detail_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/planner_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/task_editor_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/today_page.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/quick_add_field.dart';
import 'package:productivity_planner/features/voice/presentation/pages/voice_capture_page.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_notifications.dart';
import '../../helpers/fake_subscription.dart';
import '../../helpers/fake_sync.dart';
import '../../helpers/fake_task_repository.dart';
import '../../helpers/fake_voice.dart';
import '../../helpers/fakes.dart';

/// Real router, real AuthBloc + gate + cubits, fake repository.
void main() {
  late FakeAuthRepository repository;

  Future<void> pumpApp(
    WidgetTester tester, {
    required AuthState initial,
    required String initialLocation,
    SocialSignInOptions social = SocialSignInOptions.none,
  }) async {
    repository = FakeAuthRepository(initial: initial, socialOptions: social);
    final tasks = TaskCubitFactory(
      tasks: FakeTaskRepository(),
      clock: FixedClock(DateTime.utc(2026, 10, 7, 4)),
    );
    final notifications = buildNotificationCubit(
      permissions: FakeNotificationPermissions(),
      settings: FakeReminderSettings(),
    );
    addTearDown(notifications.close);
    final authBloc = AuthBloc(
      watchAuthState: WatchAuthState(repository),
      restoreSession: RestoreSession(repository),
      signOut: SignOut(repository),
    );
    final router = createAppRouter(
      authGate: AuthBlocAuthGate(authBloc),
      initialLocation: initialLocation,
      blocs: RouteBlocFactories(
        signInCubit: () => SignInCubit(
          signInWithEmail: SignInWithEmail(repository),
          signInWithApple: SignInWithApple(repository),
          signInWithGoogle: SignInWithGoogle(repository),
          getSocialSignInOptions: GetSocialSignInOptions(repository),
          watchAuthState: WatchAuthState(repository),
        ),
        registerCubit: () =>
            RegisterCubit(registerWithEmail: RegisterWithEmail(repository)),
        passwordResetCubit: (email) => PasswordResetCubit(
          requestPasswordReset: RequestPasswordReset(repository),
          resetPassword: ResetPassword(repository),
          initialEmail: email,
        ),
        profileCubit: () => ProfileCubit(
          watchAuthState: WatchAuthState(repository),
          refreshCurrentUser: RefreshCurrentUser(repository),
          updateDisplayName: UpdateDisplayName(repository),
        ),
        dailyPlannerCubit: tasks.planner,
        taskEditorCubit: tasks.editor,
        taskDetailCubit: tasks.detail,
        focusTimerBloc: tasks.focusTimer,
        analyticsCubit: tasks.analytics,
        activityAnalyticsCubit: tasks.activity,
        voiceCaptureBloc: () => tasks.voice(FakeSpeechEngine()),
        subscriptionCubit: SubscriptionHarness().cubit,
        syncStatusCubit: () => buildSyncStatusCubit(FakeSyncRepository()),
        openUrl: (_) {},
        notificationCubit: () => notifications,
        notificationPreferencesCubit: () =>
            buildPreferencesCubit(FakeNotificationPreferencesRepository()),
        onTaskSaved: () {},
        onSignOut: () => authBloc.add(const AuthSignOutRequested()),
      ),
    );
    await tester.pumpWidget(App(router: router));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'signed-out deep link → sign in with email → lands on the link',
    (tester) async {
      await pumpApp(
        tester,
        initial: const AuthState.unauthenticated(),
        initialLocation: '/occurrences/abc',
      );
      expect(find.byType(SignInPage), findsOneWidget);

      await tester.enterText(
        find.byKey(SignInPage.emailFieldKey),
        'demo@example.com',
      );
      await tester.enterText(
        find.byKey(SignInPage.passwordFieldKey),
        'password123',
      );
      await tester.tap(find.byKey(SignInPage.submitKey));
      await tester.pumpAndSettle();

      expect(find.byType(OccurrenceDetailPage), findsOneWidget);
      // The fake repository has no occurrence "abc".
      expect(find.textContaining('no longer exists'), findsOneWidget);
    },
  );

  testWidgets('empty submit shows inline errors', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.unauthenticated(),
      initialLocation: '/today',
    );

    await tester.tap(find.byKey(SignInPage.submitKey));
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(repository.signInCalls, 0);
  });

  testWidgets('session-expired notice is shown after a server sign-out', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: const AuthState.unauthenticated(
        reason: SignOutReason.sessionExpired,
      ),
      initialLocation: '/today',
    );
    expect(
      find.text('Your session ended. Please sign in again.'),
      findsOneWidget,
    );
  });

  testWidgets('social buttons appear only for available providers', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: const AuthState.unauthenticated(),
      initialLocation: '/sign-in',
      social: const SocialSignInOptions(apple: false, google: true),
    );
    expect(find.byKey(SocialSignInButtons.googleKey), findsOneWidget);
    expect(find.byKey(SocialSignInButtons.appleKey), findsNothing);
  });

  testWidgets('create account → register → signed in → Today', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.unauthenticated(),
      initialLocation: '/sign-in',
    );

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);

    await tester.enterText(find.byKey(RegisterPage.nameFieldKey), 'Anaz');
    await tester.enterText(
      find.byKey(RegisterPage.emailFieldKey),
      'anaz@example.com',
    );
    await tester.enterText(
      find.byKey(RegisterPage.passwordFieldKey),
      'long-enough-pw',
    );
    await tester.tap(find.byKey(RegisterPage.submitKey));
    await tester.pumpAndSettle();

    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('forgot password carries the typed email', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.unauthenticated(),
      initialLocation: '/sign-in',
    );

    await tester.enterText(
      find.byKey(SignInPage.emailFieldKey),
      'demo@example.com',
    );
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordPage), findsOneWidget);
    expect(find.text('demo@example.com'), findsOneWidget);
  });

  testWidgets('signed-in user sees Today and can switch tabs', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/today',
    );
    expect(find.byType(TodayPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(PlannerPage), findsOneWidget);
  });

  testWidgets('the insights tab shows analytics for this week', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/analytics',
    );
    expect(find.byType(AnalyticsPage), findsOneWidget);
    // The fake repository is empty.
    expect(find.text('Nothing was planned for this week.'), findsOneWidget);
  });

  testWidgets('the microphone on Today opens voice entry', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/today',
    );

    await tester.tap(find.byKey(QuickAddField.voiceKey));
    // Voice entry starts listening (an endless pulse): pump, don't settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(VoiceCapturePage), findsOneWidget);
    expect(find.text('Listening…'), findsOneWidget);
  });

  testWidgets('quick add opens the task editor and closing returns to Today', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/today',
    );

    await tester.tap(find.text('Add task').first);
    await tester.pumpAndSettle();
    expect(find.byType(TaskEditorPage), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('profile shows the account and saves a new name', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/settings/profile',
    );
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('demo@example.com'), findsOneWidget);

    await tester.enterText(find.byKey(ProfilePage.nameFieldKey), 'Anaz');
    await tester.tap(find.byKey(ProfilePage.saveKey));
    await tester.pumpAndSettle();

    expect(find.text('Profile updated.'), findsOneWidget);
    // Let the snackbar's dismiss timer run so no timer outlives the test.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('signing out returns to sign-in', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/settings',
    );

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.byType(SignInPage), findsOneWidget);
    expect(repository.signOutCalls, 1);
  });

  testWidgets('settings opens notification settings', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/settings',
    );

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationSettingsPage), findsOneWidget);
    expect(
      find.byKey(NotificationSettingsPage.remindersSwitchKey),
      findsOneWidget,
    );
    expect(find.text('Weekly summary'), findsOneWidget);
  });

  testWidgets('settings shows sync status and opens the sync page', (
    tester,
  ) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/settings',
    );
    // The fake starts with nothing pending and no sync this session.
    expect(find.text('Not synced yet'), findsOneWidget);

    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(find.byType(SyncPage), findsOneWidget);
    expect(find.byKey(SyncPage.syncNowKey), findsOneWidget);
  });

  testWidgets('unknown paths show the not-found page', (tester) async {
    await pumpApp(
      tester,
      initial: const AuthState.authenticated(testUser),
      initialLocation: '/does-not-exist',
    );
    expect(find.text('Go to Today'), findsOneWidget);
  });
}
