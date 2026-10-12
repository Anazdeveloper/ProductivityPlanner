# Subscriptions: setup

## How it fits together

```
App ──purchase──▶ App Store / Google Play ──▶ RevenueCat ──webhook──▶ our server
 ▲                                                                │
 └──────── GET me/entitlements (truth) + `subscription` push ◀────┘
```

- The app sells through `PurchasesGateway` (RevenueCat adapter) and asks the
  server what the user is entitled to (`SubscriptionRepository`). Every gate
  in the app asks `FeatureAccessService` (`canUse(feature)`, `limit(key)`).
- Right after a purchase the app unlocks from the store's answer
  ("Confirming your purchase…") until the server confirms, at most 24 h.
- Entitlement is cached per user for offline starts; a cached Pro more than
  3 days past its period end counts as free until the server answers.

## RevenueCat

1. Create a project with an **iOS app** and an **Android app**.
2. Products (same ids on both stores): `pro_monthly`, `pro_annual`
   (auto-renewable, one subscription group on iOS). Optional free trial on
   the annual product as an introductory offer.
3. Entitlement identifier: **`pro`** (the app reads exactly this,
   `RevenueCatPurchasesGateway.entitlementId`), attached to both products.
4. Offering: mark one offering **current**, with the `$rc_monthly` and
   `$rc_annual` packages.
5. Webhook → `POST <api>/webhooks/revenuecat` on our server (backend task;
   the server maps `app_user_id` = our user id and updates the user's plan).
6. Put the **public** SDK keys in the env files:

```json
{ "REVENUECAT_APPLE_KEY": "appl_…", "REVENUECAT_GOOGLE_KEY": "goog_…" }
```

Without a key for the platform the app shows the plans with "Purchases aren't
available in this version of the app" — fine for development. `env/dev-mock.json`
uses an in-app fake store and fake server instead.

## Native setup (after `flutter create .`)

- **iOS**: Xcode → Signing & Capabilities → add **In-App Purchase**. Test with
  a StoreKit configuration file or a sandbox account.
- **Android**: the plugin adds the billing permission. Upload a build to a
  closed testing track before products can be bought; add licence testers.

## Store review checklist

- The plans screen shows price, period, trial length and auto-renewal terms
  (done), plus working **Terms** and **Privacy** links: replace the
  placeholders in `lib/core/presentation/app_links.dart` (Phase 13).
- "Restore purchases" is on the plans screen (done).
- Subscriptions are managed in the store; the app links there.
