import 'dart:async';

import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/domain/services/speech_to_text_engine.dart';

/// A speech engine driven by the test: [say] partial words, [finish] with
/// a final transcript, or [fail].
final class FakeSpeechEngine implements SpeechToTextEngine {
  FakeSpeechEngine({this.availability = SpeechAvailability.available});

  SpeechAvailability availability;
  int listenCalls = 0;
  int stopCalls = 0;
  StreamController<SpeechEvent>? _session;

  /// Whether a listening session is open (and still listened to).
  bool get isListening => _session != null;

  @override
  Future<SpeechAvailability> prepare() async => availability;

  @override
  Stream<SpeechEvent> listen({required String language}) {
    listenCalls++;
    late final StreamController<SpeechEvent> controller;
    controller = StreamController<SpeechEvent>(
      onCancel: () {
        if (identical(_session, controller)) _session = null;
      },
    );
    _session = controller;
    return controller.stream;
  }

  @override
  Future<void> stop() async => stopCalls++;

  void say(String words) => _session?.add(SpeechPartial(words));

  void finish(String words) => _end(SpeechFinal(words));

  void fail(SpeechErrorKind kind) => _end(SpeechFailed(kind));

  void _end(SpeechEvent event) {
    final session = _session;
    if (session == null) return;
    _session = null;
    session.add(event);
    unawaited(session.close());
  }
}
