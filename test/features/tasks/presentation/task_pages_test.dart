import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/daily_planner_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/occurrence_detail_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/task_editor_page.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/today_page.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/day_overview.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/quick_add_field.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/timer_widgets.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  final today = LocalDate(2026, 10, 7);
  late FakeTaskRepository tasks;
  late TaskCubitFactory factory;

  setUp(() {
    tasks = FakeTaskRepository([
      agendaItem(
        id: 'run',
        date: today,
        title: 'Run',
        start: DateTime.utc(2026, 10, 7, 1, 30),
        status: OccurrenceStatus.completed,
      ),
      agendaItem(
        id: 'walk',
        date: today,
        title: 'Lunch walk',
        start: DateTime.utc(2026, 10, 7, 6, 30),
      ),
    ]);
    factory = TaskCubitFactory(
      tasks: tasks,
      clock: FixedClock(DateTime.utc(2026, 10, 7, 4, 30)),
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

  group('TodayPage', () {
    Widget todayPage({void Function({String? title})? onAdd}) =>
        MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => factory.planner(PlannerScope.day)..start(),
        ),
        BlocProvider(
          create: (_) => factory.focusTimer(const ActiveWorkTarget())
            ..add(const FocusTimerSubscribed()),
        ),
      ],
      child: TodayPage(
        onOpenOccurrence: (_) {},
        onAddTask: onAdd ?? ({title}) {},
      ),
    );

    testWidgets('shows progress, next task and to-do/done sections', (
      tester,
    ) async {
      await pump(tester, todayPage());

      expect(find.text('Wednesday, October 7'), findsOneWidget);
      expect(find.text('1 of 2 done'), findsOneWidget);
      expect(find.text('Next up'), findsOneWidget);
      expect(find.text('Lunch walk'), findsNWidgets(2)); // card + row
      expect(find.text('To do · 1'), findsOneWidget);
      expect(find.text('Done · 1'), findsOneWidget);
    });

    testWidgets('the next-task button completes it', (tester) async {
      await pump(tester, todayPage());

      await tester.tap(find.text('Mark as done'));
      await tester.pumpAndSettle();

      expect(tasks.actions.single.$1, 'walk');
      expect(tasks.actions.single.$2, isA<CompleteOccurrence>());
    });

    testWidgets('the next-task card starts the timer', (tester) async {
      await pump(tester, todayPage());

      await tester.tap(find.byKey(NextTaskCard.startKey));
      await tester.pumpAndSettle();

      expect(tasks.actions.single.$1, 'walk');
      expect(tasks.actions.single.$2, isA<StartOccurrence>());
    });

    testWidgets('quick add creates a task and clears the field', (
      tester,
    ) async {
      await pump(tester, todayPage());

      await tester.enterText(find.byKey(QuickAddField.fieldKey), 'Call mom');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(tasks.created.single.details.title, 'Call mom');
      final field = tester.widget<TextField>(find.byKey(QuickAddField.fieldKey));
      expect(field.controller?.text, isEmpty);
    });

    testWidgets('more options opens the editor with the typed title', (
      tester,
    ) async {
      String? opened;
      await pump(tester, todayPage(onAdd: ({title}) => opened = title));

      await tester.enterText(find.byKey(QuickAddField.fieldKey), 'Plan trip');
      await tester.tap(find.byKey(QuickAddField.moreKey));

      expect(opened, 'Plan trip');
    });
  });

  group('TaskEditorPage', () {
    testWidgets('save is enabled once there is a title and saves', (
      tester,
    ) async {
      var saved = false;
      await pump(
        tester,
        BlocProvider(
          create: (_) =>
              factory.editor(const TaskEditorArgs.create())..load(),
          child: TaskEditorPage(onClose: () {}, onSaved: () => saved = true),
        ),
      );

      final save = find.byKey(TaskEditorPage.saveKey);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.enterText(find.byKey(TaskEditorPage.titleKey), 'Read');
      await tester.pump();
      await tester.tap(save);
      await tester.pumpAndSettle();

      expect(saved, isTrue);
      expect(tasks.created.single.details.title, 'Read');
    });
  });

  group('OccurrenceDetailPage', () {
    Widget detail(String id) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => factory.detail(id)..start()),
        BlocProvider(
          create: (_) => factory.focusTimer(OccurrenceTarget(id))
            ..add(const FocusTimerSubscribed()),
        ),
      ],
      child: OccurrenceDetailPage(onEditTask: (_, _) {}, onClose: () {}),
    );

    testWidgets('mark as done (not started) applies the action', (
      tester,
    ) async {
      await pump(tester, detail('walk'));

      expect(find.text('Lunch walk'), findsOneWidget);
      await tester.tap(find.byKey(OccurrenceDetailPage.doneUnmeasuredKey));
      await tester.pumpAndSettle();

      final action = tasks.actions.single.$2;
      expect(action, isA<CompleteOccurrence>());
      expect((action as CompleteOccurrence).actualDuration, isNull);
    });

    testWidgets('Start applies the start action', (tester) async {
      await pump(tester, detail('walk'));

      expect(find.text('Start'), findsOneWidget);
      await tester.tap(find.byKey(TimerToggleButton.buttonKey));
      await tester.pumpAndSettle();

      expect(tasks.actions.single.$2, isA<StartOccurrence>());
    });

    testWidgets('a completed occurrence offers reopen', (tester) async {
      await pump(tester, detail('run'));
      expect(find.text('Reopen'), findsOneWidget);
      expect(find.byKey(OccurrenceDetailPage.completeKey), findsNothing);
      expect(find.byKey(TimerToggleButton.buttonKey), findsNothing);
    });

    testWidgets('a missing occurrence explains itself', (tester) async {
      await pump(tester, detail('missing'));
      expect(find.textContaining('no longer exists'), findsOneWidget);
    });
  });
}
