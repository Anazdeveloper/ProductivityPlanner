import 'package:get_it/get_it.dart';
import 'package:productivity_planner/core/device/connectivity_monitor.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/sync/outbox.dart';
import 'package:productivity_planner/core/sync/sync_engine.dart';
import 'package:productivity_planner/core/sync/sync_stores.dart';
import 'package:productivity_planner/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:productivity_planner/features/sync/domain/repositories/sync_repository.dart';
import 'package:productivity_planner/features/sync/domain/usecases/sync_usecases.dart';
import 'package:productivity_planner/features/sync/presentation/bloc/sync_status_cubit.dart';

/// Sync status and issues for the UI. Needs the core sync services
/// ([SyncEngine], [SyncIssueStore], [ConnectivityMonitor]) registered by
/// the composition root.
void registerSyncFeatureDependencies(GetIt getIt) {
  SyncRepository repository() => getIt<SyncRepository>();
  getIt
    ..registerLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(
        engine: getIt<SyncEngine>(),
        outbox: getIt<OutboxWriter>(),
        issues: getIt<SyncIssueStore>(),
        connectivity: getIt<ConnectivityMonitor>(),
        reporter: getIt<ErrorReporter>(),
      ),
    )
    ..registerLazySingleton(() => WatchSyncStatus(repository()))
    ..registerLazySingleton(() => SyncNow(repository()))
    ..registerLazySingleton(() => WatchSyncIssues(repository()))
    ..registerLazySingleton(() => DismissSyncIssue(repository()))
    ..registerLazySingleton(() => DismissAllSyncIssues(repository()))
    ..registerFactory(
      () => SyncStatusCubit(
        watchStatus: getIt<WatchSyncStatus>(),
        watchIssues: getIt<WatchSyncIssues>(),
        syncNow: getIt<SyncNow>(),
        dismissIssue: getIt<DismissSyncIssue>(),
        dismissAll: getIt<DismissAllSyncIssues>(),
      ),
    );
}
