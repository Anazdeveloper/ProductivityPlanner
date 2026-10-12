import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:productivity_planner/features/subscription/domain/repositories/subscription_repository.dart';

/// The current entitlement and every change.
final class WatchEntitlement {
  const WatchEntitlement(this._repository);

  final SubscriptionRepository _repository;

  Stream<Entitlement> call() => _repository.watch();
}

final class RefreshEntitlement implements UseCase<Entitlement, NoParams> {
  const RefreshEntitlement(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<Entitlement>> call(NoParams params) => _repository.refresh();
}

/// What can be bought here; empty when this build cannot sell.
final class LoadPlanOffers implements UseCase<List<PlanOffer>, NoParams> {
  const LoadPlanOffers(this._repository);

  final SubscriptionRepository _repository;

  bool get canPurchase => _repository.canPurchase;

  @override
  Future<Result<List<PlanOffer>>> call(NoParams params) async {
    if (!_repository.canPurchase) return const Ok(<PlanOffer>[]);
    return await _repository.loadOffers();
  }
}

final class PurchasePlan implements UseCase<Entitlement, String> {
  const PurchasePlan(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<Entitlement>> call(String offerId) =>
      _repository.purchase(offerId);
}

final class RestorePurchases implements UseCase<Entitlement, NoParams> {
  const RestorePurchases(this._repository);

  final SubscriptionRepository _repository;

  @override
  Future<Result<Entitlement>> call(NoParams params) => _repository.restore();
}
