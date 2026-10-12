import 'package:flutter/services.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// [PurchasesGateway] on RevenueCat, which wraps StoreKit and Google Play
/// Billing, validates receipts and tells our server about every change
/// (webhook → `me/entitlements`). Purchases are attributed to our user id
/// (`logIn`), never to an anonymous RevenueCat id once signed in.
final class RevenueCatPurchasesGateway implements PurchasesGateway {
  RevenueCatPurchasesGateway({required String apiKey}) : _apiKey = apiKey;

  /// The entitlement identifier configured in RevenueCat for Pro.
  static const entitlementId = 'pro';

  final String _apiKey;
  Future<void>? _configured;
  final Map<String, Package> _packages = {};

  @override
  bool get isAvailable => true;

  /// Configures the SDK once; the first caller's [userId] becomes the
  /// app user id.
  Future<void> _configure([String? userId]) {
    final existing = _configured;
    if (existing != null) return existing;
    final configuring = Purchases.configure(
      PurchasesConfiguration(_apiKey)..appUserID = userId,
    ).catchError((Object error, StackTrace stackTrace) {
      // Let the next call try again.
      _configured = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
    _configured = configuring;
    return configuring;
  }

  @override
  Future<void> identify(String userId) async {
    final first = _configured == null;
    await _guard(() => _configure(userId));
    if (!first) await _guard(() => Purchases.logIn(userId));
  }

  @override
  Future<void> reset() async {
    if (_configured == null) return;
    _packages.clear();
    try {
      await Purchases.logOut();
    } on PlatformException {
      // Already anonymous: nothing to forget.
    }
  }

  @override
  Future<List<PlanOffer>> offers() => _guard(() async {
    await _configure();
    final offerings = await Purchases.getOfferings();
    final packages = offerings.current?.availablePackages ?? const [];
    _packages
      ..clear()
      ..addEntries(packages.map((p) => MapEntry(p.identifier, p)));
    return [for (final package in packages) _offer(package)];
  });

  @override
  Future<StoreEntitlement> purchase(String offerId) => _guard(() async {
    await _configure();
    if (!_packages.containsKey(offerId)) await offers();
    final package =
        _packages[offerId] ??
        (throw const PurchaseException(PurchaseErrorKind.unavailable));
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return _entitlement(result.customerInfo);
  });

  @override
  Future<StoreEntitlement> restore() => _guard(() async {
    await _configure();
    return _entitlement(await Purchases.restorePurchases());
  });

  static PlanOffer _offer(Package package) {
    final product = package.storeProduct;
    final period = switch (package.packageType) {
      PackageType.monthly => OfferPeriod.monthly,
      PackageType.annual => OfferPeriod.annual,
      _ => OfferPeriod.other,
    };
    final intro = product.introductoryPrice;
    return PlanOffer(
      id: package.identifier,
      period: period,
      price: product.priceString,
      pricePerMonth: period == OfferPeriod.annual
          ? product.pricePerMonthString
          : null,
      freeTrial: intro != null && intro.price == 0
          ? _length(intro.periodUnit, intro.periodNumberOfUnits)
          : null,
    );
  }

  static Duration? _length(PeriodUnit unit, int count) => switch (unit) {
    PeriodUnit.day => Duration(days: count),
    PeriodUnit.week => Duration(days: 7 * count),
    PeriodUnit.month => Duration(days: 30 * count),
    PeriodUnit.year => Duration(days: 365 * count),
    PeriodUnit.unknown => null,
  };

  static StoreEntitlement _entitlement(CustomerInfo info) {
    final pro = info.entitlements.active[entitlementId];
    if (pro == null || !pro.isActive) {
      return StoreEntitlement(
        active: false,
        managementUrl: info.managementURL,
      );
    }
    final status = pro.billingIssueDetectedAt != null
        ? SubscriptionStatus.billingIssue
        : pro.periodType == PeriodType.trial
        ? SubscriptionStatus.trial
        : pro.willRenew
        ? SubscriptionStatus.active
        : SubscriptionStatus.cancelled;
    return StoreEntitlement(
      active: true,
      status: status,
      store: switch (pro.store) {
        Store.appStore || Store.macAppStore => BillingStore.appStore,
        Store.playStore => BillingStore.playStore,
        Store.promotional => BillingStore.promotional,
        _ => BillingStore.none,
      },
      periodEnd: DateTime.tryParse(pro.expirationDate ?? '')?.toUtc(),
      willRenew: pro.willRenew,
      managementUrl: info.managementURL,
    );
  }

  /// Maps the SDK's platform errors to [PurchaseException].
  static Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on PlatformException catch (error) {
      throw PurchaseException(
        purchaseErrorKindOf(PurchasesErrorHelper.getErrorCode(error)),
        error.message,
      );
    }
  }
}

PurchaseErrorKind purchaseErrorKindOf(PurchasesErrorCode code) =>
    switch (code) {
      PurchasesErrorCode.purchaseCancelledError => PurchaseErrorKind.cancelled,
      PurchasesErrorCode.networkError ||
      PurchasesErrorCode.offlineConnectionError =>
        PurchaseErrorKind.network,
      PurchasesErrorCode.purchaseNotAllowedError ||
      PurchasesErrorCode.insufficientPermissionsError =>
        PurchaseErrorKind.notAllowed,
      PurchasesErrorCode.paymentPendingError => PurchaseErrorKind.pending,
      PurchasesErrorCode.productNotAvailableForPurchaseError ||
      PurchasesErrorCode.configurationError ||
      PurchasesErrorCode.unsupportedError => PurchaseErrorKind.unavailable,
      _ => PurchaseErrorKind.unknown,
    };
