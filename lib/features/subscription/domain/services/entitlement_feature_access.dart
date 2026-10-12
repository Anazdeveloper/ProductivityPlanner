import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/entitlements/feature_access.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/repositories/subscription_repository.dart';

/// [FeatureAccessService] answered from the current entitlement. The one
/// place that knows plans exist; every gate in the app asks this.
final class EntitlementFeatureAccess implements FeatureAccessService {
  const EntitlementFeatureAccess(this._subscriptions);

  final SubscriptionRepository _subscriptions;

  Entitlement get _entitlement => _subscriptions.current;

  @override
  bool canUse(Feature feature) => _entitlement.canUse(feature);

  @override
  int? limit(LimitKey key) => _entitlement.limit(key);

  @override
  Stream<void> get changes => _subscriptions
      .watch()
      .map((e) => e.plan)
      .distinct()
      .skip(1)
      .map<void>((_) {});
}
