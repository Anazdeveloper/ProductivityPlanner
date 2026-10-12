import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/presentation/app_links.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/subscription/domain/entities/entitlement.dart';
import 'package:productivity_planner/features/subscription/domain/entities/plan_offer.dart';
import 'package:productivity_planner/features/subscription/domain/entities/subscription_plan.dart';
import 'package:productivity_planner/features/subscription/presentation/bloc/subscription_cubit.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Plans: what Pro adds, the store's offers, purchase and restore; for Pro
/// users, their subscription and where to manage it. Expects a
/// [SubscriptionCubit].
class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({
    required this.onClose,
    required this.onOpenUrl,
    super.key,
  });

  static const purchaseKey = Key('subscription.purchase');
  static const restoreKey = Key('subscription.restore');
  static const manageKey = Key('subscription.manage');

  final VoidCallback onClose;

  /// Opens a link outside the app (store settings, terms, privacy).
  final ValueChanged<Uri> onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<SubscriptionCubit, SubscriptionState>(
          listenWhen: (a, b) => a.failureCount != b.failureCount,
          listener: (context, state) {
            final text = state.failure?.message(l10n) ?? '';
            if (text.isNotEmpty) _snack(context, text);
          },
        ),
        BlocListener<SubscriptionCubit, SubscriptionState>(
          listenWhen: (a, b) => a.upgradedCount != b.upgradedCount,
          listener: (context, _) => _snack(context, l10n.subscriptionWelcome),
        ),
        BlocListener<SubscriptionCubit, SubscriptionState>(
          listenWhen: (a, b) =>
              a.nothingRestoredCount != b.nothingRestoredCount,
          listener: (context, _) =>
              _snack(context, l10n.subscriptionNothingToRestore),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: l10n.actionClose,
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
          title: Text(l10n.subscriptionTitle),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
                builder: (context, state) => ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: state.entitlement.isPro
                      ? [_ProStatus(state: state, onOpenUrl: onOpenUrl)]
                      : [
                          const _Header(),
                          const SizedBox(height: AppSpacing.lg),
                          _Comparison(free: state.entitlement.plan),
                          const SizedBox(height: AppSpacing.lg),
                          _Offers(state: state),
                          const SizedBox(height: AppSpacing.md),
                          _Legal(onOpenUrl: onOpenUrl),
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

String _date(BuildContext context, DateTime instant) => DateFormat.yMMMd(
  Localizations.localeOf(context).toLanguageTag(),
).format(instant.toLocal());

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.workspace_premium_outlined,
          size: 40,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          header: true,
          child: Text(
            l10n.subscriptionHeadline,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.subscriptionSubheadline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Free next to Pro, row by row; values from the free plan the server
/// sent, so the page never promises numbers the server does not apply.
class _Comparison extends StatelessWidget {
  const _Comparison({required this.free});

  final SubscriptionPlan free;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String count(LimitKey key) =>
        free.limitOf(key)?.toString() ?? l10n.planUnlimited;
    final history = free.limitOf(LimitKey.analyticsHistoryDays);
    final rows = <(String, String?, String?)>[
      (l10n.planActiveTasks, count(LimitKey.activeSeries), l10n.planUnlimited),
      (
        l10n.planRepeatingTasks,
        count(LimitKey.recurringSeries),
        l10n.planUnlimited,
      ),
      (l10n.planEveryFewDays, null, ''),
      (
        l10n.planAnalyticsHistory,
        history == null ? l10n.planAllHistory : l10n.planDays(history),
        l10n.planAllHistory,
      ),
      (l10n.planDurationSuggestions, null, ''),
    ];
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: IntrinsicColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            const SizedBox.shrink(),
            _Cell(text: l10n.planFree, style: theme.textTheme.labelLarge),
            _Cell(
              text: l10n.planPro,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        for (final (label, freeValue, proValue) in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(label, style: theme.textTheme.bodyMedium),
              ),
              _Mark(value: freeValue, included: freeValue != null),
              _Mark(value: proValue, included: true),
            ],
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    child: Text(text, style: style, textAlign: TextAlign.center),
  );
}

/// A value, or a check / dash with a spoken label (never icon alone).
class _Mark extends StatelessWidget {
  const _Mark({required this.value, required this.included});

  /// Text to show; empty or null shows a check or a dash.
  final String? value;
  final bool included;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = value;
    if (text != null && text.isNotEmpty) return _Cell(text: text);
    return Semantics(
      label: included ? l10n.planIncluded : l10n.planNotIncluded,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Icon(
          included ? Icons.check : Icons.remove,
          size: 20,
          color: included ? scheme.primary : scheme.outline,
        ),
      ),
    );
  }
}

class _Offers extends StatelessWidget {
  const _Offers({required this.state});

  final SubscriptionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SubscriptionCubit>();
    final selected = state.selectedOffer;
    final restore = TextButton(
      key: SubscriptionPage.restoreKey,
      onPressed: state.busy ? null : cubit.restore,
      child: state.restoring
          ? const _Spinner()
          : Text(l10n.subscriptionRestore),
    );
    switch (state.offersLoad) {
      case OffersLoad.loading:
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(child: CircularProgressIndicator()),
        );
      case OffersLoad.unavailable:
        return NoticeBanner(
          text: l10n.subscriptionUnavailable,
          icon: Icons.info_outline,
        );
      case OffersLoad.failure:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FailureBanner(failure: state.failure),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: cubit.loadOffers,
              child: Text(l10n.actionRetry),
            ),
            restore,
          ],
        );
      case OffersLoad.ready:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<String>(
              groupValue: state.selectedOfferId,
              onChanged: (id) {
                if (id != null) cubit.selectOffer(id);
              },
              child: Column(
                children: [
                  for (final offer in state.offers)
                    _OfferTile(offer: offer, enabled: !state.busy),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              key: SubscriptionPage.purchaseKey,
              onPressed: selected == null || state.busy ? null : cubit.purchase,
              child: state.purchasing
                  ? const _Spinner()
                  : Text(
                      selected?.freeTrial != null
                          ? l10n.subscriptionStartTrial
                          : l10n.subscriptionSubscribe,
                    ),
            ),
            restore,
          ],
        );
    }
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.enabled});

  final PlanOffer offer;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final trial = offer.freeTrial;
    final perMonth = offer.pricePerMonth;
    final title = switch (offer.period) {
      OfferPeriod.annual => l10n.offerAnnual(offer.price),
      OfferPeriod.monthly => l10n.offerMonthly(offer.price),
      OfferPeriod.other => offer.price,
    };
    final details = [
      if (perMonth != null) l10n.offerPerMonth(perMonth),
      if (trial != null) l10n.offerTrial(trial.inDays),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: RadioListTile<String>(
        key: Key('offer.${offer.id}'),
        value: offer.id,
        enabled: enabled,
        title: Text(title),
        subtitle: details.isEmpty ? null : Text(details.join(' · ')),
      ),
    );
  }
}

class _Legal extends StatelessWidget {
  const _Legal({required this.onOpenUrl});

  final ValueChanged<Uri> onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.subscriptionLegal,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              onPressed: () => onOpenUrl(AppLinks.terms),
              child: Text(l10n.linkTerms),
            ),
            TextButton(
              onPressed: () => onOpenUrl(AppLinks.privacy),
              child: Text(l10n.linkPrivacy),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProStatus extends StatelessWidget {
  const _ProStatus({required this.state, required this.onOpenUrl});

  final SubscriptionState state;
  final ValueChanged<Uri> onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final entitlement = state.entitlement;
    final end = entitlement.periodEnd;
    final manage = entitlement.manageUrl;
    final status = switch (entitlement.status) {
      SubscriptionStatus.trial when end != null => l10n.statusTrialEnds(
        _date(context, end),
      ),
      SubscriptionStatus.cancelled when end != null => l10n.statusEnds(
        _date(context, end),
      ),
      SubscriptionStatus.billingIssue => l10n.statusBillingIssue,
      _ when end != null && entitlement.willRenew => l10n.statusRenews(
        _date(context, end),
      ),
      _ => l10n.statusActive,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.workspace_premium,
          size: 48,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            l10n.subscriptionYouArePro,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          status,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (!entitlement.verified) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.subscriptionConfirming,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (entitlement.status == SubscriptionStatus.billingIssue) ...[
          const SizedBox(height: AppSpacing.md),
          NoticeBanner(
            text: l10n.statusBillingIssueHelp,
            icon: Icons.credit_card_off_outlined,
            isError: true,
          ),
        ],
        if (manage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            key: SubscriptionPage.manageKey,
            onPressed: () => onOpenUrl(Uri.parse(manage)),
            child: Text(l10n.subscriptionManage),
          ),
        ],
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
