import 'package:productivity_planner/features/voice/domain/entities/speech.dart';

/// Turns speech into text. An interface so the provider (the platform
/// recognizer today; a cloud service later) can be replaced without
/// touching the rest of the pipeline.
abstract interface class SpeechToTextEngine {
  /// Gets the recognizer ready, asking for microphone and speech access
  /// the first time.
  Future<SpeechAvailability> prepare();

  /// Listens until the person pauses or [stop] is called. One session at a
  /// time; cancelling the subscription cancels the session. [language] is
  /// a BCP 47 language (`en`); the engine picks a matching recognizer
  /// locale, preferring the device's own.
  Stream<SpeechEvent> listen({required String language});

  /// Stops listening; the final transcript follows on the stream.
  Future<void> stop();
}
