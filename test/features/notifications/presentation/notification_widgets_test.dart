import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_access.dart';
import 'package:productivity_planner/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:productivity_planner/features/notifications/presentation/widgets/reminders_off_banner.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/fake_notifications.dart';

void main() {
  Future<NotificationCubit> pumpBanner(
    WidgetTester tester,
    FakeNotificationPermissions permissions,
  ) async {
    final cubit = buildNotificationCubit(
      permissions: permissions,
      settings: FakeReminderSettings(),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const RemindersOffBanner(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('hidden when reminders can be delivered', (tester) async {
    await pumpBanner(tester, FakeNotificationPermissions());
    expect(find.byKey(RemindersOffBanner.turnOnKey), findsNothing);
  });

  testWidgets('"Turn on" prompts and the banner goes away', (tester) async {
    final permissions = FakeNotificationPermissions(
      permission: NotificationPermission.notDetermined,
    );
    await pumpBanner(tester, permissions);
    expect(find.text('Reminders are off for this app.'), findsOneWidget);

    await tester.tap(find.byKey(RemindersOffBanner.turnOnKey));
    await tester.pumpAndSettle();

    expect(permissions.requests, 1);
    expect(find.byKey(RemindersOffBanner.turnOnKey), findsNothing);
  });

  testWidgets('after a refusal it offers the system settings', (tester) async {
    final permissions = FakeNotificationPermissions(
      permission: NotificationPermission.denied,
    );
    await pumpBanner(tester, permissions);
    expect(find.text('Open settings'), findsOneWidget);

    await tester.tap(find.byKey(RemindersOffBanner.turnOnKey));
    await tester.pumpAndSettle();
    expect(permissions.settingsOpened, 1);
  });
}
