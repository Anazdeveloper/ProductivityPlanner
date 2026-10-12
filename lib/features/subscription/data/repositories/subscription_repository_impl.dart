import 'dart:async';

import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/network/remote_call.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/features/subscription/data/datasources/entitlement_cache.dart';
import 'package:productivity_planner/features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'package:productivity_planner/features/subscription/data/purchases/purchases_gateway.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';
import 'package:productivity_planner/features/subscription/domain/repositories/subscription_repository.dart';

/// Entitlement from the server, purchases through a [PurchasesGateway].
///
/// - The server's answer is the truth; it is cached per user for offline
///   starts.
/// - A store purchase or restore unlocks Pro at once ("provisional",
///   `verified: false`) because the server learns about it a moment later
///   (store → RevenueCat → webhook). The provisional unlock lasts until the
///   server confirms Pro, or [provisionalFor] at most.
/// - A cached Pro whose period ended more than [lapseGrace] ago counts as
///   free until the server says otherwise (a phone kept offline does not
///   keep Pro forever).
final class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required SubscriptionRemoteDataSource remote,
    required PurchasesGateway gateway,
    required EntitlementCache cache,
    required Clock clock,
    required AppLogger logger,
    required ErrorReporter reporter,
    this.provisionalFor = const Duration(hours: 24),
    this.lapseGrace = const Duration(days: 3),
  }) : _remote = remote,
       _gateway = gateway,
       _cache = cache,
       _clock = clock,
       _logger = logger,
       _reporter = reporter;

  final SubscriptionRemoteDataSource _remote;
  final PurchasesGateway _gateway;
  final EntitlementCache _cache;
  final Clock _clock;
  final AppLogger _logger;
  final ErrorReporter _reporter;
  final Duration provisionalFor;
  final Duration lapseGrace;

  final _changes = StreamController<Entitlement>.broadcast(sync: true);

  /// The last server answer (or the cache), before provisional/lapse rules.
  Entitlement _server = Entitlement.free;

  /// What [current] last published to [watch].
  Entitlement _published = Entitlement.free;
  String? _userId;

  /// Set by a store purchase/restore until the server confirms it.
  ({Entitlement entitlement, DateTime until})? _provisional;

  /// Evaluated on every read, so the 24 h provisional limit and the lapse
  /// rule apply even when no server answer arrives (offline).
  @override
  Entitlement get current {
    final provisional = _provisional;
    final now = _clock.now();
    final base = _lapsed(_server, now);
    if (provisional != null && !base.isPro) {
      if (now.isBefore(provisional.until)) return provisional.entitlement;
      _provisional = null;
    }
    return base;
  }

  @override
  Stream<Entitlement> watch() => Stream<Entitlement>.multi((controller) {
    controller.add(current);
    final subscription = _changes.stream.listen(controller.add);
    controller.onCancel = subscription.cancel;
  });

  @override
  bool get canPurchase => _gateway.isAvailable;

  @override
  Future<void> bindUser(String userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _provisional = null;
    final cached = await _readCache(userId);
    if (_userId != userId) return;
    _setServer(cached ?? Entitlement.free);
    try {
      await _gateway.identify(userId);
    } on PurchaseException catch (error) {
      // Selling may not work right now; entitlement still comes from the
      // server.
      _logger.warning(
        'Purchases: identify failed',
        context: {'kind': error.kind.name},
      );
    }
  }

  @override
  Future<void> unbindUser() async {
    _userId = null;
    _provisional = null;
    _setServer(Entitlement.free);
    try {
      await _cache.clear();
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'cache'});
    }
    try {
      await _gateway.reset();
    } on Object catch (error, stackTrace) {
      // Nothing to undo locally; the next sign-in identifies again.
      _logger.warning(
        'Purchases: reset failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Result<Entitlement>> refresh() async {
    final userId = _userId;
    if (userId == null) return const Ok(Entitlement.free);
    // Time-based rules (provisional limit, lapse) may have changed what
    // applies; tell listeners before the network answers.
    _publish();
    final result = await guardRemoteCall(
      _remote.getEntitlement,
      reporter: _reporter,
    );
    if (_userId != userId) return Ok(current);
    switch (result) {
      case Ok(:final value):
        if (value.isPro) _provisional = null;
        _setServer(value);
        await _writeCache(userId, value);
        return Ok(current);
      case Err(:final failure):
        return Err(failure);
    }
  }

  @override
  Future<Result<List<PlanOffer>>> loadOffers() =>
      _store(() async => Ok(await _gateway.offers()));

  @override
  Future<Result<Entitlement>> purchase(String offerId) =>
      _store(() async => _applyStore(await _gateway.purchase(offerId)));

  @override
  Future<Result<Entitlement>> restore() =>
      _store(() async => _applyStore(await _gateway.restore()));

  /// Runs a store call: provider errors become failures, anything else is
  /// reported, so the plans screen never stays busy.
  Future<Result<T>> _store<T>(Future<Result<T>> Function() body) async {
    try {
      return await body();
    } on PurchaseException catch (error) {
      return Err(_failure(error));
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'store'});
      return Err(Failure.unexpected(cause: error, stackTrace: stackTrace));
    }
  }

  /// Unlocks from the store's answer, then asks the server. A failed
  /// server check does not undo the purchase.
  Future<Result<Entitlement>> _applyStore(StoreEntitlement store) async {
    if (store.active) {
      final now = _clock.now();
      _provisional = (
        entitlement: Entitlement(
          plan: _server.isPro ? _server.plan : SubscriptionPlan.pro,
          status: store.status,
          store: store.store,
          periodEnd: store.periodEnd,
          willRenew: store.willRenew,
          managementUrl: store.managementUrl,
          verified: false,
          updatedAt: now,
        ),
        until: now.add(provisionalFor),
      );
      _publish();
    }
    await refresh();
    return Ok(current);
  }

  /// A cached Pro long past its period counts as free.
  Entitlement _lapsed(Entitlement entitlement, DateTime now) {
    final end = entitlement.periodEnd;
    if (!entitlement.isPro || end == null) return entitlement;
    return now.isAfter(end.add(lapseGrace))
        ? Entitlement.free.copyWith(status: SubscriptionStatus.expired)
        : entitlement;
  }

  void _setServer(Entitlement entitlement) {
    _server = entitlement;
    _publish();
  }

  void _publish() {
    final next = current;
    if (next == _published) return;
    _published = next;
    _changes.add(next);
  }

  Future<Entitlement?> _readCache(String userId) async {
    try {
      return await _cache.read(userId);
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'cache'});
      return null;
    }
  }

  /// A failed cache write only costs the offline copy.
  Future<void> _writeCache(String userId, Entitlement entitlement) async {
    try {
      await _cache.write(userId, entitlement);
    } on Object catch (error, stackTrace) {
      await _reporter.report(error, stackTrace, context: {'step': 'cache'});
    }
  }

  static Failure _failure(PurchaseException error) => switch (error.kind) {
    PurchaseErrorKind.cancelled => const Failure.cancelled(),
    PurchaseErrorKind.network => const Failure.network(),
    PurchaseErrorKind.notAllowed => const Failure.conflict(
      code: 'PURCHASE_NOT_ALLOWED',
    ),
    PurchaseErrorKind.pending => const Failure.conflict(
      code: 'PURCHASE_PENDING',
    ),
    PurchaseErrorKind.unavailable => const Failure.conflict(
      code: 'PURCHASES_UNAVAILABLE',
    ),
    PurchaseErrorKind.unknown => const Failure.server(code: 'STORE_ERROR'),
  };
}
