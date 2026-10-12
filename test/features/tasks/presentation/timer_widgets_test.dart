import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';
import 'package:productivity_planner/features/tasks/domain/services/occurrence_lifecycle.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/focus_timer_bloc.dart';
import 'package:productivity_planner/features/tasks/presentation/formatting/task_formatters.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/active_work_card.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/timer/focus_timer_feedback.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  final today = LocalDate(2026, 10, 7);
  final started = DateTime.utc(2026, 10, 7, 4);

  test('formatElapsed', () {
    expect(formatElapsed(const Duration(seconds: 5)), '0:05');
    expect(formatElapsed(const Duration(minutes: 12, seconds: 5)), '12:05');
    expect(formatElapsed(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03');
    expect(formatElapsed(const Duration(seconds: -4)), '0:00');
  });

  group('ActiveWorkCard', () {
    late FixedClock clock;
    late ManualTicker ticker;
    late FakeTaskRepository tasks;

    setUp(() {
      clock = FixedClock(started.add(const Duration(minutes: 3)));
      ticker = ManualTicker();
      tasks = FakeTaskRepository([
        agendaItem(
          id: 'write',
          date: today,
          title: 'Write report',
          start: started,
          status: OccurrenceStatus.inProgress,
          sessions: [
            WorkSession(id: 's', occurrenceId: 'write', startedAt: started),
          ],
        ),
      ]);
    });

    Future<void> pump(WidgetTester tester) async {
      final factory = TaskCubitFactory(
        tasks: tasks,
        clock: clock,
        ticker: ticker,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider(
              create: (_) => factory.focusTimer(const ActiveWorkTarget())
                ..add(const FocusTimerSubscribed()),
              child: FocusTimerFeedback(
                child: ActiveWorkCard(onOpen: (_) {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows the live elapsed time and the plan', (tester) async {
      await pump(tester);

      expect(find.text('Working on'), findsOneWidget);
      expect(find.text('Write report'), findsOneWidget);
      expect(find.text('3:00'), findsOneWidget);
      expect(find.text('27 min left'), findsOneWidget);

      clock.current = clock.current.add(const Duration(seconds: 42));
      ticker.tick(clock.current);
      await tester.pump();
      expect(find.text('3:42'), findsOneWidget);
    });

    testWidgets('pause and done send the lifecycle actions', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();
      expect(tasks.actions.last.$2, isA<PauseOccurrence>());

      await tester.tap(find.byKey(ActiveWorkCard.doneKey));
      await tester.pumpAndSettle();
      expect(tasks.actions.last.$2, isA<CompleteOccurrence>());
      expect(
        (tasks.actions.last.$2 as CompleteOccurrence).actualDuration,
        isNull,
        reason: 'the tracked time is used',
      );
    });

    testWidgets('a forgotten timer asks before completing', (tester) async {
      clock.current = started.add(const Duration(hours: 10));
      await pump(tester);

      await tester.tap(find.byKey(ActiveWorkCard.doneKey));
      await tester.pumpAndSettle();

      expect(find.text('That was a long one'), findsOneWidget);
      expect(tasks.actions, isEmpty);

      await tester.tap(find.text('Keep 10 h'));
      await tester.pumpAndSettle();
      expect(tasks.actions.single.$2, isA<CompleteOccurrence>());
    });

    testWidgets('renders nothing when nothing is in progress', (tester) async {
      tasks.items = const [];
      await pump(tester);
      expect(find.text('Working on'), findsNothing);
      expect(find.text('Paused'), findsNothing);
    });
  });
}
