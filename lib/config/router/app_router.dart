import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_planner/config/router/app_routes.dart';
import 'package:productivity_planner/config/router/app_shell.dart';
import 'package:productivity_planner/config/router/auth_gate.dart';
import 'package:productivity_planner/config/router/auth_redirect.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/activity_analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/pages/activity_detail_page.dart';
import 'package:productivity_planner/features/analytics/presentation/pages/analytics_page.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/password_reset_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/register_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/bloc/sign_in_cubit.dart';
import 'package:productivity_planner/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:productivity_planner/features/auth/presentation/pages/register_page.dart';
import 'package:productivity_planner/features/auth/presentation/pages/sign_in_page.dart';
import 'package:productivity_planner/features/auth/presentation/pages/splash_page.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_preferences_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/pages/notification_settings_page.dart';
import 'package:productivity_planner/features/notifications/presentation/widgets/reminders_off_banner.dart';
import 'package:productivity_planner/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:productivity_planner/features/profile/presentation/pages/profile_page.dart';
import 'package:productivity_planner/features/settings/presentation/pages/settings_page.dart';
import 'package:productivity_planner/features/subscription/presentation/bloc/subscription_cubit.dart';
import 'package:productivity_planner/features/subscription/presentation/pages/subscription_page.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';
import 'package:productivity_planner/features/sync/presentation/pages/sync_page.dart';
import 'package:productivity_planner/features/sync/presentation/widgets/sync_settings_tile.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_detail_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/occurrence_detail_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/planner_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/task_editor_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/today_page.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/editor/prefill_summary.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';
import 'package:productivity_planner/features/voice/presentation/pages/voice_capture_page.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Factories for the blocs routes create. Plain functions (not the service
/// locator) so router tests can supply fakes.
final class RouteBlocFactories {
  const RouteBlocFactories({
    required this.signInCubit,
    required this.registerCubit,
    required this.passwordResetCubit,
    required this.profileCubit,
    required this.dailyPlannerCubit,
    required this.taskEditorCubit,
    required this.taskDetailCubit,
    required this.focusTimerBloc,
    required this.analyticsCubit,
    required this.activityAnalyticsCubit,
    required this.voiceCaptureBloc,
    required this.subscriptionCubit,
    required this.syncStatusCubit,
    required this.openUrl,
    required this.notificationCubit,
    required this.notificationPreferencesCubit,
    required this.onTaskSaved,
    required this.onSignOut,
  });

  final SignInCubit Function() signInCubit;
  final RegisterCubit Function() registerCubit;
  final PasswordResetCubit Function(String initialEmail) passwordResetCubit;
  final ProfileCubit Function() profileCubit;
  final DailyPlannerCubit Function(PlannerScope scope) dailyPlannerCubit;
  final TaskEditorCubit Function(TaskEditorArgs args) taskEditorCubit;
  final TaskDetailCubit Function(String occurrenceId) taskDetailCubit;
  final FocusTimerBloc Function(FocusTarget target) focusTimerBloc;
  final AnalyticsCubit Function() analyticsCubit;
  final ActivityAnalyticsCubit Function(String lineageId)
  activityAnalyticsCubit;
  final VoiceCaptureBloc Function() voiceCaptureBloc;
  final SubscriptionCubit Function() subscriptionCubit;
  final SyncStatusCubit Function() syncStatusCubit;

  /// Opens a link outside the app.
  final ValueChanged<Uri> openUrl;

  /// The app-wide instance (shared by Today's banner and the settings
  /// page); routes provide it with `BlocProvider.value` and never close it.
  final NotificationCubit Function() notificationCubit;
  final NotificationPreferencesCubit Function() notificationPreferencesCubit;

  /// After the editor saves: the moment to ask for notification permission
  /// if the new task has a reminder that could not be delivered.
  final VoidCallback onTaskSaved;
  final VoidCallback onSignOut;
}

/// Builds the app's router. Pages receive data and callbacks from here, and
/// their blocs are provided here, so no page imports the router or the
/// service locator.
GoRouter createAppRouter({
  required AuthGate authGate,
  required RouteBlocFactories blocs,
  String initialLocation = AppRoutes.today,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: authGate,
    redirect: (_, state) => resolveAuthRedirect(authGate.status, state.uri),
    errorBuilder: (context, state) => _NotFoundPage(
      location: state.uri.toString(),
      onGoHome: () => context.go(AppRoutes.today),
    ),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => AppRoutes.today),
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) {
          // Carry `from` through register / reset so a deep link survives
          // the whole sign-up detour.
          final from = state.uri.queryParameters['from'];
          return BlocProvider(
            create: (_) => blocs.signInCubit()..loadOptions(),
            child: SignInPage(
              onCreateAccount: () =>
                  context.push(_withFrom(AppRoutes.register, from)),
              onForgotPassword: (email) => context.push(
                _withQuery(AppRoutes.forgotPassword, 'email', email.trim()),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return BlocProvider(
            create: (_) => blocs.registerCubit(),
            child: RegisterPage(
              onSignIn: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(_withFrom(AppRoutes.signIn, from));
                }
              },
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => blocs.passwordResetCubit(
            state.uri.queryParameters['email'] ?? '',
          ),
          child: ForgotPasswordPage(
            onBackToSignIn: () => context.go(AppRoutes.signIn),
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, _) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          blocs.dailyPlannerCubit(PlannerScope.day)..start(),
                    ),
                    BlocProvider(
                      create: (_) =>
                          blocs.focusTimerBloc(const ActiveWorkTarget())
                            ..add(const FocusTimerSubscribed()),
                    ),
                  ],
                  child: TodayPage(
                    onOpenOccurrence: (id) =>
                        context.push(AppRoutes.occurrence(id)),
                    onAddTask: ({title}) =>
                        context.push(AppRoutes.newTask(title: title)),
                    onVoiceAdd: () => context.push(AppRoutes.voiceTask),
                    onOpenPlans: () => context.push(AppRoutes.subscription),
                    banner: BlocProvider.value(
                      value: blocs.notificationCubit(),
                      child: const RemindersOffBanner(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.planner,
                builder: (context, _) => BlocProvider(
                  create: (_) =>
                      blocs.dailyPlannerCubit(PlannerScope.week)..start(),
                  child: PlannerPage(
                    onOpenOccurrence: (id) =>
                        context.push(AppRoutes.occurrence(id)),
                    onAddTask: (date) =>
                        context.push(AppRoutes.newTask(date: date)),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.analytics,
                builder: (context, _) => BlocProvider(
                  create: (_) => blocs.analyticsCubit()..start(),
                  child: AnalyticsPage(
                    onOpenActivity: (lineageId) =>
                        context.go(AppRoutes.activity(lineageId)),
                    onOpenPlans: () => context.push(AppRoutes.subscription),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.activityPattern,
                    builder: (context, state) => BlocProvider(
                      create: (_) => blocs.activityAnalyticsCubit(
                        state.pathParameters['lineageId'] ?? '',
                      )..start(),
                      child: ActivityDetailPage(
                        onOpenPlans: () =>
                            context.push(AppRoutes.subscription),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, _) => SettingsPage(
                  onOpenProfile: () => context.go(AppRoutes.profile),
                  onOpenSubscription: () =>
                      context.push(AppRoutes.subscription),
                  onOpenNotifications: () =>
                      context.go(AppRoutes.notificationSettings),
                  onSignOut: blocs.onSignOut,
                  syncTile: BlocProvider(
                    create: (_) => blocs.syncStatusCubit()..start(),
                    child: SyncSettingsTile(
                      onTap: () => context.go(AppRoutes.syncSettings),
                    ),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (_, _) => BlocProvider(
                      create: (_) => blocs.profileCubit()..refresh(),
                      child: const ProfilePage(),
                    ),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (_, _) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: blocs.notificationCubit()),
                        BlocProvider(
                          create: (_) =>
                              blocs.notificationPreferencesCubit()..load(),
                        ),
                      ],
                      child: const NotificationSettingsPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'sync',
                    builder: (_, _) => BlocProvider(
                      create: (_) => blocs.syncStatusCubit()..start(),
                      child: const SyncPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.createTask,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _editorPage(
          context,
          state,
          blocs,
          TaskEditorArgs.create(
            date: LocalDate.tryParse(state.uri.queryParameters['date']),
            title: state.uri.queryParameters['title'],
            // A draft from voice entry (not part of the URL, so a deep link
            // or restored route opens an empty editor).
            prefill: switch (state.extra) {
              final TaskPrefill prefill => prefill,
              _ => null,
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.voiceTask,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          fullscreenDialog: true,
          child: BlocProvider(
            create: (_) =>
                blocs.voiceCaptureBloc()..add(const VoiceCaptureStarted()),
            child: VoiceCapturePage(
              // Replace, so Back from the editor returns to where voice
              // entry started.
              onReview: (prefill) =>
                  context.pushReplacement(AppRoutes.createTask, extra: prefill),
              onClose: () => _closeOrGoHome(context),
              summaryBuilder: (prefill, today, categoryName) =>
                  TaskPrefillSummary(
                    prefill: prefill,
                    today: today,
                    categoryName: categoryName,
                  ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.editTaskPattern,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _editorPage(
          context,
          state,
          blocs,
          TaskEditorArgs.edit(
            taskId: state.pathParameters['taskId'] ?? '',
            editFrom: LocalDate.tryParse(state.uri.queryParameters['from']),
          ),
        ),
      ),
      GoRoute(
        // Target of reminder taps and notification actions.
        path: AppRoutes.occurrencePattern,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final occurrenceId = state.pathParameters['occurrenceId'] ?? '';
          return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => blocs.taskDetailCubit(occurrenceId)..start(),
            ),
            BlocProvider(
              create: (_) =>
                  blocs.focusTimerBloc(OccurrenceTarget(occurrenceId))
                    ..add(const FocusTimerSubscribed()),
            ),
          ],
          child: OccurrenceDetailPage(
            onEditTask: (taskId, from) async {
              // A schedule edit can replace this occurrence (new series or
              // date), so the detail closes after a save rather than
              // showing a stale or vanished item.
              final saved = await context.push<bool>(
                AppRoutes.editTask(taskId, from: from),
              );
              if ((saved ?? false) && context.mounted) _closeOrGoHome(context);
            },
            onClose: () => _closeOrGoHome(context),
            onOpenActivity: (lineageId) =>
                context.go(AppRoutes.activity(lineageId)),
          ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.subscription,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          fullscreenDialog: true,
          child: BlocProvider(
            create: (_) => blocs.subscriptionCubit()..start(),
            child: SubscriptionPage(
              onClose: () => _closeOrGoHome(context),
              onOpenUrl: blocs.openUrl,
            ),
          ),
        ),
      ),
    ],
  );
}

Page<void> _editorPage(
  BuildContext context,
  GoRouterState state,
  RouteBlocFactories blocs,
  TaskEditorArgs args,
) => MaterialPage<void>(
  key: state.pageKey,
  fullscreenDialog: true,
  child: BlocProvider(
    create: (_) => blocs.taskEditorCubit(args)..load(),
    child: TaskEditorPage(
      onOpenPlans: () => context.push(AppRoutes.subscription),
      onClose: () => _closeOrGoHome(context),
      onSaved: () {
        blocs.onTaskSaved();
        _closeOrGoHome(context, result: true);
      },
    ),
  ),
);

String _withFrom(String path, String? from) =>
    _withQuery(path, 'from', safeInternalLocation(from));

/// Adds `?key=value` only when there is a value (an empty query map would
/// still serialise a trailing `?`).
String _withQuery(String path, String key, String? value) =>
    value == null || value.isEmpty
    ? path
    : Uri(path: path, queryParameters: {key: value}).toString();

/// A modal opened by a deep link has nothing beneath it to pop back to.
void _closeOrGoHome(BuildContext context, {bool? result}) {
  if (context.canPop()) {
    context.pop(result);
  } else {
    context.go(AppRoutes.today);
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location, required this.onGoHome});

  final String location;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.notFoundMessage),
            Text(location, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: onGoHome, child: Text(l10n.actionGoToToday)),
          ],
        ),
      ),
    );
  }
}
