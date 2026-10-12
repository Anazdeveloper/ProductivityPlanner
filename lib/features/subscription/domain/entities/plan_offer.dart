import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_offer.freezed.dart';

enum OfferPeriod { monthly, annual, other }

/// Something the store can sell right now, with its localized price.
@freezed
abstract class PlanOffer with _$PlanOffer {
  const factory PlanOffer({
    /// The provider's package id; passed back to purchase it.
    required String id,
    required OfferPeriod period,

    /// Store-formatted price, e.g. "₹299.00".
    required String price,

    /// For annual offers: the price per month, store-formatted.
    String? pricePerMonth,

    /// A free trial, if the person is eligible ("1 week").
    Duration? freeTrial,
  }) = _PlanOffer;
}
