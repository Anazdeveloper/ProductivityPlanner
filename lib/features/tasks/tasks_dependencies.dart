import 'package:get_it/get_it.dart';
import 'package:productivity_planner/core/database/app_database.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/data/datasources/category_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:productivity_planner/features/tasks/data/datasources/task_sync_remote_data_source.dart';
import 'package:productivity_planner/features/tasks/data/repositories/category_repository_impl.dart';
import 'package:productivity_planner/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:productivity_planner/features/tasks/data/sync/task_sync_handler.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/category_repository.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/agenda_summarizer.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_planner.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_status_resolver.dart';
import 'package:productivity_planner/features/tasks/domain/services/postpone_targets.dart';
import 'package:productivity_planner/features/tasks/domain/services/recurrence_expander.dart';
import 'package:productivity_planner/features/tasks/domain/services/task_plan_policy.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/create_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/edit_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/occurrence_actions.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_detail_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';

/// Tasks feature registrations. Requires core and database registrations,
/// a [FeatureAccessService] (plan limits) and a [HomeTimeZone] (registered by the composition root, which knows
/// about the user's profile).
///
/// Screen cubits are factories (one per route); everything else is a lazy
/// singleton.
void registerTaskDependencies(GetIt getIt) {
  // Domain services (pure, stateless)
  getIt
    ..registerLazySingleton(() => TaskRules(getIt<TimeZoneConverter>()))
    ..registerLazySingleton(RecurrenceExpander.new)
    ..registerLazySingleton(OccurrenceStatusResolver.new)
    ..registerLazySingleton(
      () => OccurrencePlanner(
        expander: getIt<RecurrenceExpander>(),
        converter: getIt<TimeZoneConverter>(),
      ),
    )
    ..registerLazySingleton(
      () => OccurrenceLifecycle(
        ids: getIt<IdGenerator>(),
        converter: getIt<TimeZoneConverter>(),
      ),
    )
    ..registerLazySingleton(
      () => AgendaSummarizer(
        resolver: getIt<OccurrenceStatusResolver>(),
        converter: getIt<TimeZoneConverter>(),
      ),
    )
    ..registerLazySingleton(
      () => PostponeTargets(getIt<TimeZoneConverter>()),
    )
    ..registerLazySingleton(
      () => TaskPlanPolicy(getIt<FeatureAccessService>()),
    );

  // Data
  getIt
    ..registerLazySingleton(() => TaskLocalDataSource(getIt<AppDatabase>()))
    ..registerLazySingleton(() => CategoryLocalDataSource(getIt<AppDatabase>()))
    ..registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
        local: getIt<TaskLocalDataSource>(),
        outbox: getIt<OutboxWriter>(),
        planner: getIt<OccurrencePlanner>(),
        lifecycle: getIt<OccurrenceLifecycle>(),
        converter: getIt<TimeZoneConverter>(),
        ids: getIt<IdGenerator>(),
        clock: getIt<Clock>(),
        reporter: getIt<ErrorReporter>(),
      ),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        local: getIt<CategoryLocalDataSource>(),
        outbox: getIt<OutboxWriter>(),
        ids: getIt<IdGenerator>(),
        clock: getIt<Clock>(),
        reporter: getIt<ErrorReporter>(),
      ),
    );

  // Sync: the engine (registered by the composition root) applies pulled
  // series, occurrences, sessions and categories through this handler.
  getIt
    ..registerLazySingleton<TaskSyncRemoteDataSource>(
      () => HttpTaskSyncRemoteDataSource(getIt<ApiHttpClient>()),
    )
    ..registerLazySingleton(
      () => TaskSyncHandler(
        tasks: getIt<TaskLocalDataSource>(),
        categories: getIt<CategoryLocalDataSource>(),
        remote: getIt<TaskSyncRemoteDataSource>(),
        repository: getIt<TaskRepository>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    );

  // Use cases
  TaskRepository tasks() => getIt<TaskRepository>();
  CategoryRepository categories() => getIt<CategoryRepository>();
  getIt
    ..registerLazySingleton(
      () => CreateTask(
        repository: tasks(),
        rules: getIt<TaskRules>(),
        policy: getIt<TaskPlanPolicy>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(
      () => UpdateTaskDetails(repository: tasks(), rules: getIt<TaskRules>()),
    )
    ..registerLazySingleton(
      () => RescheduleTaskFrom(
        repository: tasks(),
        rules: getIt<TaskRules>(),
        policy: getIt<TaskPlanPolicy>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(
      () => EndTask(
        repository: tasks(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(() => DeleteTask(tasks()))
    ..registerLazySingleton(() => GetTask(tasks()))
    ..registerLazySingleton(() => WatchAgenda(tasks()))
    ..registerLazySingleton(() => WatchAgendaItem(tasks()))
    ..registerLazySingleton(() => WatchActiveWork(tasks()))
    ..registerLazySingleton(WorkTimer.new)
    ..registerLazySingleton(
      () => GetHomeTimeZone(
        homeTimeZone: getIt<HomeTimeZone>(),
        converter: getIt<TimeZoneConverter>(),
      ),
    )
    ..registerLazySingleton(
      () => GetHomeToday(
        homeTimeZone: getIt<HomeTimeZone>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton(() => ApplyOccurrenceAction(tasks()))
    ..registerLazySingleton(() => EnsureOccurrencesMaterialized(tasks()))
    ..registerLazySingleton(() => WatchCategories(categories()))
    ..registerLazySingleton(
      () => CreateCategory(repository: categories(), rules: getIt<TaskRules>()),
    )
    ..registerLazySingleton(() => EnsureDefaultCategories(categories()));

  // Screen cubits
  getIt
    ..registerFactoryParam<DailyPlannerCubit, PlannerScope, void>(
      (scope, _) => DailyPlannerCubit(
        scope: scope,
        watchAgenda: getIt<WatchAgenda>(),
        getHomeToday: getIt<GetHomeToday>(),
        getHomeTimeZone: getIt<GetHomeTimeZone>(),
        applyAction: getIt<ApplyOccurrenceAction>(),
        createTask: getIt<CreateTask>(),
        summarizer: getIt<AgendaSummarizer>(),
        clock: getIt<Clock>(),
        ticker: getIt<Ticker>(),
      ),
    )
    ..registerFactoryParam<TaskEditorCubit, TaskEditorArgs, void>(
      (args, _) => TaskEditorCubit(
        args: args,
        createTask: getIt<CreateTask>(),
        updateTaskDetails: getIt<UpdateTaskDetails>(),
        rescheduleTaskFrom: getIt<RescheduleTaskFrom>(),
        getTask: getIt<GetTask>(),
        getHomeTimeZone: getIt<GetHomeTimeZone>(),
        watchCategories: getIt<WatchCategories>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerFactoryParam<TaskDetailCubit, String, void>(
      (occurrenceId, _) => TaskDetailCubit(
        occurrenceId: occurrenceId,
        watchAgendaItem: getIt<WatchAgendaItem>(),
        applyAction: getIt<ApplyOccurrenceAction>(),
        endTask: getIt<EndTask>(),
        deleteTask: getIt<DeleteTask>(),
        summarizer: getIt<AgendaSummarizer>(),
        postponeTargets: getIt<PostponeTargets>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
        ticker: getIt<Ticker>(),
      ),
    )
    // The timer shows seconds, so it gets its own one-second ticker; it
    // only listens while a session is running.
    ..registerFactoryParam<FocusTimerBloc, FocusTarget, void>(
      (target, _) => FocusTimerBloc(
        target: target,
        watchActiveWork: getIt<WatchActiveWork>(),
        watchAgendaItem: getIt<WatchAgendaItem>(),
        applyAction: getIt<ApplyOccurrenceAction>(),
        workTimer: getIt<WorkTimer>(),
        clock: getIt<Clock>(),
        ticker: PeriodicTicker(
          getIt<Clock>(),
          interval: const Duration(seconds: 1),
        ),
      ),
    );
}
