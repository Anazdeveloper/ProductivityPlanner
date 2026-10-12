import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/features/subscription/presentation/pages/subscription_page.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/fake_subscription.dart';

void main() {
  late SubscriptionHarness h;
  late List<Uri> opened;

  setUp(() {
    h = SubscriptionHarness();
    opened = [];
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) => h.cubit()..start(),
          child: SubscriptionPage(onClose: () {}, onOpenUrl: opened.add),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('free: compares plans, offers a trial, buys', (tester) async {
    await h.repository.bindUser('u1');
    h.gateway.storeState = storePro;
    await pump(tester);

    expect(find.text('Plan more. Learn more.'), findsOneWidget);
    expect(find.text('20'), findsOneWidget, reason: 'free active tasks');
    expect(find.text(r'$39.99 per year'), findsOneWidget);
    expect(find.text(r'$3.33 a month · 7-day free trial'), findsOneWidget);
    expect(find.text('Start free trial'), findsOneWidget);

    await tester.ensureVisible(find.byKey(SubscriptionPage.purchaseKey));
    await tester.tap(find.byKey(SubscriptionPage.purchaseKey));
    await tester.pumpAndSettle();

    expect(h.gateway.purchases, ['annual']);
    expect(find.text('Welcome to Pro!'), findsOneWidget);
    expect(find.text("You're on Pro"), findsOneWidget);
    expect(
      find.text('Confirming your purchase with our server…'),
      findsOneWidget,
    );
  });

  testWidgets('Pro: shows renewal and opens store management', (
    tester,
  ) async {
    h.cache.byUser['u1'] = proEntitlement;
    await h.repository.bindUser('u1');
    h.remote.entitlement = proEntitlement;
    await pump(tester);

    expect(find.text("You're on Pro"), findsOneWidget);
    expect(find.textContaining('Renews on'), findsOneWidget);

    await tester.tap(find.byKey(SubscriptionPage.manageKey));
    expect(
      opened.single,
      Uri.parse('https://apps.apple.com/account/subscriptions'),
    );
  });
}
