import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:productivity_planner/features/subscription/domain/usecases/subscription_usecases.dart';

part 'subscription_cubit.freezed.dart';

enum OffersLoad {
  loading,
  ready,

  /// This build cannot sell (no store configured).
  unavailable,
  failure,
}

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(Entitlement.free) Entitlement entitlement,
    @Default(OffersLoad.loading) OffersLoad offersLoad,
    @Default(<PlanOffer>[]) List<PlanOffer> offers,
    String? selectedOfferId,
    @Default(false) bool purchasing,
    @Default(false) bool restoring,

    /// The last failure; [failureCount] changes with each one.
    Failure? failure,
    @Default(0) int failureCount,

    /// Changes when a purchase or restore made the user Pro.
    @Default(0) int upgradedCount,

    /// Changes when a restore found nothing.
    @Default(0) int nothingRestoredCount,
  }) = _SubscriptionState;

  const SubscriptionState._();

  PlanOffer? get selectedOffer {
    for (final offer in offers) {
      if (offer.id == selectedOfferId) return offer;
    }
    return null;
  }

  bool get busy => purchasing || restoring;
}

/// The plans screen: current entitlement, store offers, purchase and
/// restore. A Cubit: plain commands, one at a time.
final class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({
    required WatchEntitlement watchEntitlement,
    required RefreshEntitlement refreshEntitlement,
    required LoadPlanOffers loadOffers,
    required PurchasePlan purchasePlan,
    required RestorePurchases restorePurchases,
  }) : _watchEntitlement = watchEntitlement,
       _refreshEntitlement = refreshEntitlement,
       _loadOffers = loadOffers,
       _purchasePlan = purchasePlan,
       _restorePurchases = restorePurchases,
       super(const SubscriptionState());

  final WatchEntitlement _watchEntitlement;
  final RefreshEntitlement _refreshEntitlement;
  final LoadPlanOffers _loadOffers;
  final PurchasePlan _purchasePlan;
  final RestorePurchases _restorePurchases;

  StreamSubscription<Entitlement>? _entitlement;

  /// Follows the entitlement, loads offers and asks the server for the
  /// latest state. Call once.
  void start() {
    _entitlement ??= _watchEntitlement().listen(
      (value) => emit(state.copyWith(entitlement: value)),
    );
    unawaited(_refreshEntitlement(const NoParams()));
    unawaited(loadOffers());
  }

  Future<void> loadOffers() async {
    if (!_loadOffers.canPurchase) {
      emit(state.copyWith(offersLoad: OffersLoad.unavailable));
      return;
    }
    emit(state.copyWith(offersLoad: OffersLoad.loading));
    final result = await _loadOffers(const NoParams());
    if (isClosed) return;
    switch (result) {
      case Ok(:final value) when value.isEmpty:
        emit(state.copyWith(offersLoad: OffersLoad.unavailable, offers: value));
      case Ok(:final value):
        emit(
          state.copyWith(
            offersLoad: OffersLoad.ready,
            offers: value,
            selectedOfferId: _defaultOffer(value).id,
          ),
        );
      case Err(:final failure):
        // Shown in place (with a retry), not as a snackbar too.
        emit(state.copyWith(offersLoad: OffersLoad.failure, failure: failure));
    }
  }

  /// Annual first (the better deal), else the first offer.
  static PlanOffer _defaultOffer(List<PlanOffer> offers) {
    for (final offer in offers) {
      if (offer.period == OfferPeriod.annual) return offer;
    }
    return offers.first;
  }

  void selectOffer(String offerId) {
    if (state.busy) return;
    emit(state.copyWith(selectedOfferId: offerId));
  }

  Future<void> purchase() async {
    final offer = state.selectedOffer;
    if (offer == null || state.busy) return;
    emit(state.copyWith(purchasing: true));
    final result = await _purchasePlan(offer.id);
    if (isClosed) return;
    _finish(result, fromRestore: false);
  }

  Future<void> restore() async {
    if (state.busy) return;
    emit(state.copyWith(restoring: true));
    final result = await _restorePurchases(const NoParams());
    if (isClosed) return;
    _finish(result, fromRestore: true);
  }

  void _finish(Result<Entitlement> result, {required bool fromRestore}) {
    switch (result) {
      case Ok(:final value) when value.isPro:
        emit(
          state.copyWith(
            purchasing: false,
            restoring: false,
            entitlement: value,
            upgradedCount: state.upgradedCount + 1,
          ),
        );
      case Ok(:final value):
        emit(
          state.copyWith(
            purchasing: false,
            restoring: false,
            entitlement: value,
            nothingRestoredCount: fromRestore
                ? state.nothingRestoredCount + 1
                : state.nothingRestoredCount,
          ),
        );
      case Err(:final failure):
        emit(
          state.copyWith(
            purchasing: false,
            restoring: false,
            failure: failure,
            failureCount: state.failureCount + 1,
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _entitlement?.cancel();
    await super.close();
  }
}
