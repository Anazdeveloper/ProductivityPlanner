import 'package:get_it/get_it.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/ticker.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/analytics/data/repositories/local_analytics_repository.dart';
import 'package:productivity_planner/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:productivity_planner/features/analytics/domain/services/analytics_calculator.dart';
import 'package:productivity_planner/features/analytics/domain/usecases/analytics_usecases.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/activity_analytics_cubit.dart';
import 'package:productivity_planner/features/analytics/presentation/bloc/analytics_cubit.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/edit_task.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';

/// Analytics registrations. Requires the tasks registrar (history comes
/// from the task repository) and a [FeatureAccessService].
void registerAnalyticsDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton(
      () => AnalyticsCalculator(getIt<TimeZoneConverter>()),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => LocalAnalyticsRepository(getIt<TaskRepository>()),
    )
    ..registerLazySingleton(
      () => WatchPeriodRecords(getIt<AnalyticsRepository>()),
    )
    ..registerLazySingleton(
      () => WatchActivityRecords(getIt<AnalyticsRepository>()),
    )
    ..registerLazySingleton(
      () => GetAnalyticsAccess(getIt<FeatureAccessService>()),
    )
    ..registerLazySingleton(
      () => ApplyDurationSuggestion(
        getTask: getIt<GetTask>(),
        updateTaskDetails: getIt<UpdateTaskDetails>(),
      ),
    )
    ..registerFactory(
      () => AnalyticsCubit(
        watchPeriodRecords: getIt<WatchPeriodRecords>(),
        getHomeToday: getIt<GetHomeToday>(),
        getAccess: getIt<GetAnalyticsAccess>(),
        calculator: getIt<AnalyticsCalculator>(),
        clock: getIt<Clock>(),
        ticker: getIt<Ticker>(),
      ),
    )
    ..registerFactoryParam<ActivityAnalyticsCubit, String, void>(
      (lineageId, _) => ActivityAnalyticsCubit(
        lineageId: lineageId,
        watchActivityRecords: getIt<WatchActivityRecords>(),
        getHomeToday: getIt<GetHomeToday>(),
        getAccess: getIt<GetAnalyticsAccess>(),
        applySuggestion: getIt<ApplyDurationSuggestion>(),
        calculator: getIt<AnalyticsCalculator>(),
        clock: getIt<Clock>(),
      ),
    );
}
