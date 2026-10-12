import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/presentation/pages/activity_detail_page.dart';
import 'package:productivity_planner/features/analytics/presentation/pages/analytics_page.dart';
import 'package:productivity_planner/features/analytics/presentation/widgets/charts/analytics_charts.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_feature_access.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository tasks;
  late TaskCubitFactory factory;

  setUp(() {
    tasks = FakeTaskRepository([
      agendaItem(
        id: 'mon',
        date: LocalDate(2026, 10, 5),
        lineageId: 'run',
        title: 'Run',
        status: OccurrenceStatus.completed,
        actual: const Duration(minutes: 40),
      ),
      agendaItem(
        id: 'tue',
        date: LocalDate(2026, 10, 6),
        lineageId: 'run',
        title: 'Run',
      ),
    ]);
    factory = TaskCubitFactory(
      tasks: tasks,
      clock: FixedClock(DateTime.utc(2026, 10, 7, 6, 30)),
    );
  });

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('AnalyticsPage', () {
    String? opened;

    Widget page() => BlocProvider(
      create: (_) => factory.analytics()..start(),
      child: AnalyticsPage(
        onOpenActivity: (id) => opened = id,
        onOpenPlans: () {},
      ),
    );

    setUp(() => opened = null);

    testWidgets('shows the week with tiles and charts', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, page());

      expect(find.text('Oct 5 – 11'), findsOneWidget);
      expect(find.byKey(const Key('metric.completion')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('metric.completion')),
          matching: find.text('50%'),
        ),
        findsOneWidget,
        reason: '1 done, 1 missed',
      );
      expect(find.text('1 of 2 done'), findsOneWidget);
      expect(find.byType(OutcomeChart), findsOneWidget);
      await tester.ensureVisible(find.byType(OutcomeChart));
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(
          'Mon, Oct 5: 1 done, 0 skipped, 0 missed, 0 to do',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('tapping a bar opens that day', (tester) async {
      await pump(tester, page());

      final monday = find.byKey(const Key('${OutcomeChart.barKeyPrefix}0'));
      await tester.ensureVisible(monday);
      await tester.pumpAndSettle();
      await tester.tap(monday);
      await tester.pumpAndSettle();

      // The header may have scrolled above the viewport.
      expect(find.text('Mon, Oct 5', skipOffstage: false), findsOneWidget);
      expect(find.text('Plan vs actual'), findsOneWidget);
    });

    testWidgets('previous goes to last week, which was empty', (tester) async {
      await pump(tester, page());

      await tester.tap(find.byKey(AnalyticsPage.previousKey));
      await tester.pumpAndSettle();

      expect(find.text('Sep 28 – Oct 4'), findsOneWidget);
      expect(find.text('Nothing was planned for this week.'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
    });

    testWidgets('an activity row opens its analytics', (tester) async {
      await pump(tester, page());

      final row = find.byKey(const Key('activity.run'));
      await tester.scrollUntilVisible(
        row,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(row);
      expect(opened, 'run');
    });
  });

  group('ActivityDetailPage', () {
    testWidgets('offers and applies a learned duration', (tester) async {
      tasks.items = [
        for (var day = 1; day <= 6; day++)
          agendaItem(
            id: 'run-$day',
            date: LocalDate(2026, 10, day),
            lineageId: 'run',
            title: 'Run',
            status: OccurrenceStatus.completed,
            actual: const Duration(minutes: 45),
          ),
      ];
      await pump(
        tester,
        BlocProvider(
          create: (_) => factory.activity(
            'run',
            access: const FakeFeatureAccess(advancedAnalytics: true),
          )..start(),
          child: ActivityDetailPage(onOpenPlans: () {}),
        ),
      );

      expect(find.text('Run'), findsOneWidget); // app bar
      expect(find.text('6 in a row'), findsOneWidget);
      expect(find.text('Suggested duration'), findsOneWidget);

      await tester.ensureVisible(find.byKey(ActivityDetailPage.applyKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ActivityDetailPage.applyKey));
      await tester.pumpAndSettle();

      expect(
        tasks.detailUpdates.single.$2.plannedDuration,
        const Duration(minutes: 45),
      );
      expect(find.text('Expected duration updated'), findsOneWidget);
    });
  });
}
