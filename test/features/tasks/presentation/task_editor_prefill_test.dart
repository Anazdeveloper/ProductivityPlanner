import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/task_editor_page.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/quick_add_field.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  late FakeTaskRepository tasks;
  late TaskCubitFactory factory;

  setUp(() {
    tasks = FakeTaskRepository();
    factory = TaskCubitFactory(
      tasks: tasks,
      // 10:00 in Kolkata, Wednesday 7 October 2026.
      clock: FixedClock(DateTime.utc(2026, 10, 7, 4, 30)),
    );
  });

  Future<void> settle() => pumpEventQueue();

  group('TaskEditorCubit with a prefill', () {
    test('fills the form from the draft', () async {
      final cubit = factory.editor(
        TaskEditorArgs.create(
          prefill: TaskPrefill(
            title: ' Run ',
            date: LocalDate(2026, 10, 8),
            time: LocalTime(7, 0),
            duration: const Duration(minutes: 45),
            recurrence: const RecurrenceRule(
              frequency: RecurrenceFrequency.weekly,
              weekdays: [1, 3],
            ),
            categoryId: 'c-health',
            originText: 'Run tomorrow at 7',
          ),
        ),
      )..load();
      addTearDown(cubit.close);
      await settle();

      final state = cubit.state;
      expect(state.status, EditorStatus.editing);
      expect(state.title, 'Run');
      expect(state.date, LocalDate(2026, 10, 8));
      expect(state.time, LocalTime(7, 0));
      expect(state.duration, const Duration(minutes: 45));
      expect(state.frequency, RecurrenceFrequency.weekly);
      expect(state.weekdays, [1, 3]);
      expect(state.categoryId, 'c-health');
      expect(state.originText, 'Run tomorrow at 7');
      expect(tasks.created, isEmpty, reason: 'nothing is saved yet');
    });

    test('"any time" clears the time; weekly without days uses the date', () async {
      final cubit = factory.editor(
        TaskEditorArgs.create(
          prefill: TaskPrefill(
            date: LocalDate(2026, 10, 9),
            anyTime: true,
            recurrence: const RecurrenceRule(
              frequency: RecurrenceFrequency.weekly,
              interval: 2,
            ),
          ),
        ),
      )..load();
      addTearDown(cubit.close);
      await settle();

      expect(cubit.state.time, isNull);
      expect(cubit.state.interval, 2);
      expect(cubit.state.weekdays, [5], reason: 'Friday 9 October');
    });

    test('a past date is moved to today', () async {
      final cubit = factory.editor(
        TaskEditorArgs.create(prefill: TaskPrefill(date: LocalDate(2026, 1, 1))),
      )..load();
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.date, LocalDate(2026, 10, 7));
    });
  });

  testWidgets('the editor shows what was said and saves only on Save', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) => factory.editor(
            const TaskEditorArgs.create(
              prefill: TaskPrefill(title: 'Call mom', originText: 'call mom'),
            ),
          )..load(),
          child: TaskEditorPage(onClose: () {}, onSaved: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(TaskEditorPage.originKey), findsOneWidget);
    expect(
      find.text('From what you said: “call mom”. Check the details, then save.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byKey(TaskEditorPage.titleKey)).controller?.text,
      'Call mom',
    );
    expect(tasks.created, isEmpty);

    await tester.tap(find.byKey(TaskEditorPage.saveKey));
    await tester.pumpAndSettle();
    expect(tasks.created.single.details.title, 'Call mom');
  });

  testWidgets('quick add shows the microphone only when voice is offered', (
    tester,
  ) async {
    var voice = 0;
    Future<void> pump({VoidCallback? onVoice}) => tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: QuickAddField(
            onSubmit: (_) async => true,
            onMoreOptions: (_) {},
            onVoice: onVoice,
          ),
        ),
      ),
    );

    await pump();
    expect(find.byKey(QuickAddField.voiceKey), findsNothing);

    await pump(onVoice: () => voice++);
    await tester.tap(find.byKey(QuickAddField.voiceKey));
    expect(voice, 1);
  });
}
