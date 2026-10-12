import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/tasks/presentation/widgets/editor/prefill_summary.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';
import 'package:productivity_planner/features/voice/presentation/pages/voice_capture_page.dart';
import 'package:productivity_planner/features/voice/presentation/widgets/listening_button.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fake_voice.dart';
import '../../../helpers/fakes.dart';

void main() {
  late FakeSpeechEngine engine;
  late TaskCubitFactory factory;
  TaskPrefill? reviewed;

  setUp(() {
    reviewed = null;
    engine = FakeSpeechEngine();
    factory = TaskCubitFactory(
      tasks: FakeTaskRepository(),
      clock: FixedClock(DateTime.utc(2026, 10, 7, 4, 30)),
      categories: FakeCategoryRepository(const [
        Category(id: 'c-health', name: 'Health', color: CategoryColor.green),
      ]),
    );
  });

  // The listening pulse and spinners repeat forever, so these tests pump
  // frames instead of settling while listening.
  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) =>
              factory.voice(engine)..add(const VoiceCaptureStarted()),
          child: VoiceCapturePage(
            onReview: (prefill) => reviewed = prefill,
            onClose: () {},
            summaryBuilder: (prefill, today, category) => TaskPrefillSummary(
              prefill: prefill,
              today: today,
              categoryName: category,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('listen, review what was understood, continue', (tester) async {
    await pumpPage(tester);
    expect(find.byKey(ListeningButton.buttonKey), findsOneWidget);
    expect(find.text('Listening…'), findsOneWidget);

    engine.say('Run tomorrow');
    await tester.pump();
    expect(find.text('Run tomorrow'), findsOneWidget);

    engine.finish('Run tomorrow at 7 for 30 minutes');
    await tester.pumpAndSettle();

    expect(find.text('“Run tomorrow at 7 for 30 minutes”'), findsOneWidget);
    expect(find.text("Here's what I understood"), findsOneWidget);
    expect(find.textContaining('Tomorrow'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget, reason: 'no repetition');

    await tester.tap(find.byKey(VoiceCapturePage.continueKey));
    expect(reviewed?.title, 'Run');
    expect(reviewed?.duration, const Duration(minutes: 30));
    expect(reviewed?.originText, 'Run tomorrow at 7 for 30 minutes');
  });

  testWidgets('tapping the microphone stops listening', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byKey(ListeningButton.buttonKey));
    await tester.pump();
    expect(engine.stopCalls, 1);
  });

  testWidgets('without microphone access the task can be typed', (
    tester,
  ) async {
    engine.availability = SpeechAvailability.permissionDenied;
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Microphone access is needed to add tasks by voice.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(VoiceCapturePage.typedFieldKey),
      'Water plants every 2 days',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('“Water plants every 2 days”'), findsOneWidget);
    expect(find.text('Every 2 days'), findsOneWidget);
  });

  testWidgets('nothing heard offers to try again', (tester) async {
    await pumpPage(tester);
    engine.fail(SpeechErrorKind.noSpeech);
    await tester.pumpAndSettle();

    expect(
      find.text('Nothing was heard. Try again a little closer to the microphone.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(VoiceCapturePage.retryKey));
    await tester.pump();
    await tester.pump();
    expect(engine.listenCalls, 2);
    expect(find.byKey(ListeningButton.buttonKey), findsOneWidget);
  });
}
