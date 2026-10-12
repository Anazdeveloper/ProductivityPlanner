/// Whether speech recognition can be used on this device right now.
enum SpeechAvailability {
  available,

  /// The person declined microphone or speech-recognition access.
  permissionDenied,

  /// The device has no recognizer (or it is disabled).
  unsupported,
}

enum SpeechErrorKind {
  permissionDenied,

  /// Nothing was heard, or nothing could be matched to words.
  noSpeech,

  /// Recognition needed the network and it was not reachable.
  network,

  /// The recognizer is in use by another app.
  busy,
  unknown,
}

/// What a listening session reports, in order: partial transcripts, then
/// one final transcript or an error, then the stream closes.
sealed class SpeechEvent {
  const SpeechEvent();
}

/// The words so far; replaced by each later event.
final class SpeechPartial extends SpeechEvent {
  const SpeechPartial(this.text);

  final String text;
}

final class SpeechFinal extends SpeechEvent {
  const SpeechFinal(this.text);

  final String text;
}

final class SpeechFailed extends SpeechEvent {
  const SpeechFailed(this.kind);

  final SpeechErrorKind kind;
}
