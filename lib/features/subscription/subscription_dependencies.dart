import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:productivity_planner/config/env/app_environment.dart';
import 'package:productivity_planner/core/database/app_meta_store.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/subscription/data/datasources/entitlement_cache.dart';
import 'package:productivity_planner/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:productivity_planner/features/subscription/data/mock/subscription_mock.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/data/purchases/revenuecat_purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:productivity_planner/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:productivity_planner/features/subscription/domain/services/entitlement_feature_access.dart';
import 'package:productivity_planner/features/subscription/domain/usecases/subscription_usecases.dart';
import 'package:productivity_planner/features/subscription/presentation/bloc/subscription_cubit.dart';

/// Subscriptions and the app-wide [FeatureAccessService]. The store
/// provider is chosen here only:
///
/// - mock backend builds: an in-app fake store;
/// - a RevenueCat key for this platform: RevenueCat;
/// - otherwise: plans are shown, nothing is sold.
void registerSubscriptionDependencies(GetIt getIt) {
  final environment = getIt<AppEnvironment>();

  if (environment.useMockApi) {
    final backend = SubscriptionMockBackend(clock: getIt<Clock>())
      ..register(getIt<MockApiAdapter>());
    getIt.registerSingleton<PurchasesGateway>(MockPurchasesGateway(backend));
  } else {
    final key = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS =>
        environment.revenueCatAppleKey,
      TargetPlatform.android => environment.revenueCatGoogleKey,
      _ => null,
    };
    getIt.registerLazySingleton<PurchasesGateway>(
      () => key == null
          ? const UnavailablePurchasesGateway()
          : RevenueCatPurchasesGateway(apiKey: key),
    );
  }

  getIt
    ..registerLazySingleton<SubscriptionRemoteDataSource>(
      () => HttpSubscriptionRemoteDataSource(getIt<ApiHttpClient>()),
    )
    ..registerLazySingleton<EntitlementCache>(
      () => MetaEntitlementCache(getIt<AppMetaStore>()),
    )
    ..registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(
        remote: getIt<SubscriptionRemoteDataSource>(),
        gateway: getIt<PurchasesGateway>(),
        cache: getIt<EntitlementCache>(),
        clock: getIt<Clock>(),
        logger: getIt<AppLogger>(),
        reporter: getIt<ErrorReporter>(),
      ),
    )
    ..registerLazySingleton<FeatureAccessService>(
      () => EntitlementFeatureAccess(getIt<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => WatchEntitlement(getIt<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => RefreshEntitlement(getIt<SubscriptionRepository>()),
    )
    ..registerLazySingleton(
      () => LoadPlanOffers(getIt<SubscriptionRepository>()),
    )
    ..registerLazySingleton(() => PurchasePlan(getIt<SubscriptionRepository>()))
    ..registerLazySingleton(
      () => RestorePurchases(getIt<SubscriptionRepository>()),
    )
    ..registerFactory(
      () => SubscriptionCubit(
        watchEntitlement: getIt<WatchEntitlement>(),
        refreshEntitlement: getIt<RefreshEntitlement>(),
        loadOffers: getIt<LoadPlanOffers>(),
        purchasePlan: getIt<PurchasePlan>(),
        restorePurchases: getIt<RestorePurchases>(),
      ),
    );
}
