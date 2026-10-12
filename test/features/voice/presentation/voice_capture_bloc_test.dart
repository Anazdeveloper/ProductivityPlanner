import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';

import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fake_voice.dart';
import '../../../helpers/fakes.dart';

void main() {
  late FakeSpeechEngine engine;
  late TaskCubitFactory factory;

  setUp(() {
    engine = FakeSpeechEngine();
    factory = TaskCubitFactory(
      tasks: FakeTaskRepository(),
      // 10:00 in Kolkata on Wednesday 7 October 2026.
      clock: FixedClock(DateTime.utc(2026, 10, 7, 4, 30)),
      categories: FakeCategoryRepository(const [
        Category(id: 'c-health', name: 'Health', color: CategoryColor.green),
      ]),
    );
  });

  Future<void> settle() => pumpEventQueue();

  VoiceCaptureBloc start() {
    final bloc = factory.voice(engine)..add(const VoiceCaptureStarted());
    addTearDown(bloc.close);
    return bloc;
  }

  test('listens, shows partial words, then a draft to review', () async {
    final bloc = start();
    await settle();
    expect(bloc.state.phase, VoicePhase.listening);
    expect(engine.isListening, isTrue);

    engine.say('Run tomorrow');
    await settle();
    expect(bloc.state.transcript, 'Run tomorrow');

    engine.finish('Run tomorrow at 7 for 30 minutes');
    await settle();

    expect(bloc.state.phase, VoicePhase.review);
    final draft = bloc.state.draft;
    expect(draft?.title, 'Run');
    expect(draft?.date, LocalDate(2026, 10, 8));
    expect(draft?.startTime, LocalTime(7, 0));
    expect(draft?.expectedDuration, const Duration(minutes: 30));
    expect(draft?.category?.id, 'c-health');
  });

  test('stop asks the engine to finish', () async {
    final bloc = start();
    await settle();
    bloc.add(const VoiceStopPressed());
    await settle();
    expect(engine.stopCalls, 1);
  });

  test('no permission: unavailable, typing still works', () async {
    engine.availability = SpeechAvailability.permissionDenied;
    final bloc = start();
    await settle();
    expect(bloc.state.phase, VoicePhase.unavailable);
    expect(bloc.state.availability, SpeechAvailability.permissionDenied);
    expect(engine.listenCalls, 0);

    bloc.add(const VoiceTextSubmitted('Call mom at 6 pm'));
    await settle();
    expect(bloc.state.phase, VoicePhase.review);
    expect(bloc.state.draft?.startTime, LocalTime(18, 0));
  });

  test('nothing heard: failed, and try again listens anew', () async {
    final bloc = start();
    await settle();
    engine.fail(SpeechErrorKind.noSpeech);
    await settle();
    expect(bloc.state.phase, VoicePhase.failed);
    expect(bloc.state.error, SpeechErrorKind.noSpeech);

    bloc.add(const VoiceRetryPressed());
    await settle();
    expect(bloc.state.phase, VoicePhase.listening);
    expect(engine.listenCalls, 2);
  });

  test('an error after some words keeps what was heard', () async {
    final bloc = start();
    await settle();
    engine.say('Water plants every 2 days');
    await settle();
    engine.fail(SpeechErrorKind.network);
    await settle();
    expect(bloc.state.phase, VoicePhase.review);
    expect(bloc.state.draft?.title, 'Water plants');
  });

  test('a typed correction replaces the listening session', () async {
    final bloc = start();
    await settle();
    bloc.add(const VoiceTextSubmitted('Gym tomorrow evening'));
    await settle();
    expect(engine.isListening, isFalse, reason: 'the session was cancelled');
    expect(bloc.state.draft?.startTime, LocalTime(19, 0));

    // A late event from the abandoned session changes nothing.
    engine.finish('ignored');
    await settle();
    expect(bloc.state.draft?.title, 'Gym');
  });

  test('a mid-session permission error shows the unavailable state', () async {
    final bloc = start();
    await settle();
    engine.fail(SpeechErrorKind.permissionDenied);
    await settle();
    expect(bloc.state.phase, VoicePhase.unavailable);
  });
}
