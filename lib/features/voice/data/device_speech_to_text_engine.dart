import 'dart:async';

import 'package:flutter/services.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/domain/services/speech_to_text_engine.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// [SpeechToTextEngine] on the platform recognizer (Apple Speech on iOS,
/// the system recognition service on Android) through `speech_to_text`.
///
/// Audio is handled by the operating system's recognizer; the app only
/// receives text. Some devices recognize on the device, others send the
/// audio to the platform vendor's service (stated in the privacy texts,
/// docs/VOICE_SETUP.md).
final class DeviceSpeechToTextEngine implements SpeechToTextEngine {
  DeviceSpeechToTextEngine([SpeechToText? speech])
    : _speech = speech ?? SpeechToText();

  /// Listening ends after this much silence, or after [_maxListen].
  static const _pause = Duration(seconds: 3);
  static const _maxListen = Duration(seconds: 30);

  final SpeechToText _speech;
  StreamController<SpeechEvent>? _session;
  String _lastWords = '';

  @override
  Future<SpeechAvailability> prepare() async {
    bool ready;
    try {
      // Asks for microphone (and, on iOS, speech recognition) access the
      // first time. A failed attempt is not cached by the plugin, so a
      // later call works after the person allows access in Settings.
      ready = await _speech.initialize(onError: _onError, onStatus: _onStatus);
    } on PlatformException {
      ready = false;
    }
    if (ready) return SpeechAvailability.available;
    final permitted = await _speech.hasPermission;
    return permitted
        ? SpeechAvailability.unsupported
        : SpeechAvailability.permissionDenied;
  }

  @override
  Stream<SpeechEvent> listen({required String language}) {
    unawaited(_session?.close());
    late final StreamController<SpeechEvent> controller;
    controller = StreamController<SpeechEvent>(
      onCancel: () async {
        if (identical(_session, controller)) {
          _session = null;
          await _speech.cancel();
        }
      },
    );
    _session = controller;
    _lastWords = '';
    unawaited(_start(controller, language));
    return controller.stream;
  }

  Future<void> _start(
    StreamController<SpeechEvent> controller,
    String language,
  ) async {
    try {
      final localeId = await _localeFor(language);
      // Cancelled (or replaced) while the locale was looked up: do not
      // turn the microphone on for nobody.
      if (!identical(_session, controller)) return;
      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          pauseFor: _pause,
          listenFor: _maxListen,
          localeId: localeId,
        ),
      );
    } on Object {
      if (identical(_session, controller)) {
        _finish(const SpeechFailed(SpeechErrorKind.unknown));
      }
    }
  }

  @override
  Future<void> stop() => _speech.stop();

  /// The device's own locale if it speaks [language], else the first
  /// recognizer locale that does; null lets the platform choose.
  Future<String?> _localeFor(String language) async {
    bool speaks(String id) =>
        id.toLowerCase().replaceAll('-', '_').split('_').first == language;
    final system = await _speech.systemLocale();
    if (system != null && speaks(system.localeId)) return system.localeId;
    for (final locale in await _speech.locales()) {
      if (speaks(locale.localeId)) return locale.localeId;
    }
    return null;
  }

  void _onResult(SpeechRecognitionResult result) {
    final session = _session;
    if (session == null) return;
    _lastWords = result.recognizedWords;
    if (result.finalResult) {
      _finish(SpeechFinal(_lastWords));
    } else {
      session.add(SpeechPartial(_lastWords));
    }
  }

  void _onError(SpeechRecognitionError error) {
    _finish(SpeechFailed(errorKindOf(error.errorMsg)));
  }

  void _onStatus(String status) {
    // "done" without a final result: end with what was heard, if anything.
    if (status == SpeechToText.doneStatus) {
      _finish(
        _lastWords.trim().isEmpty
            ? const SpeechFailed(SpeechErrorKind.noSpeech)
            : SpeechFinal(_lastWords),
      );
    }
  }

  void _finish(SpeechEvent event) {
    final session = _session;
    if (session == null) return;
    _session = null;
    session.add(event);
    unawaited(session.close());
  }
}

/// Maps the plugin's platform error codes (see `SpeechErrorListener`).
SpeechErrorKind errorKindOf(String code) => switch (code) {
  'error_permission' ||
  'error_speech_recognizer_request_not_authorized' =>
    SpeechErrorKind.permissionDenied,
  'error_no_match' ||
  'error_speech_timeout' ||
  'error_audio_error' => SpeechErrorKind.noSpeech,
  'error_network' ||
  'error_network_timeout' ||
  'error_server' ||
  'error_server_disconnected' ||
  'error_too_many_requests' => SpeechErrorKind.network,
  'error_busy' ||
  'error_speech_recognizer_already_active' => SpeechErrorKind.busy,
  _ => SpeechErrorKind.unknown,
};
