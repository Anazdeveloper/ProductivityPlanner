import 'package:productivity_planner/core/entitlements/feature.dart';

/// What the signed-in user's plan allows. The rest of the app asks this,
/// never "is premium", so where entitlements come from (the server, the
/// App Store, Google Play, RevenueCat) stays behind one seam.
///
/// Implemented by the subscription feature from the user's current
/// entitlement (server-confirmed, cached for offline use).
abstract interface class FeatureAccessService {
  bool canUse(Feature feature);

  /// The plan's value for [key]; null means unlimited.
  int? limit(LimitKey key);

  /// Emits whenever the answers above may have changed (upgrade, expiry,
  /// sign-in as someone else).
  Stream<void> get changes;
}

/// Everything allowed, nothing ever changes. For tests and tools.
final class UnrestrictedFeatureAccess implements FeatureAccessService {
  const UnrestrictedFeatureAccess();

  @override
  bool canUse(Feature feature) => true;

  @override
  int? limit(LimitKey key) => null;

  @override
  Stream<void> get changes => const Stream.empty();
}
