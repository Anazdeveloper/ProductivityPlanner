import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/features/voice/data/device_speech_to_text_engine.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';

void main() {
  test('platform error codes map to error kinds', () {
    expect(errorKindOf('error_permission'), SpeechErrorKind.permissionDenied);
    expect(
      errorKindOf('error_speech_recognizer_request_not_authorized'),
      SpeechErrorKind.permissionDenied,
    );
    expect(
      errorKindOf('error_speech_recognizer_already_active'),
      SpeechErrorKind.busy,
    );
    expect(errorKindOf('error_no_match'), SpeechErrorKind.noSpeech);
    expect(errorKindOf('error_speech_timeout'), SpeechErrorKind.noSpeech);
    expect(errorKindOf('error_network'), SpeechErrorKind.network);
    expect(errorKindOf('error_server'), SpeechErrorKind.network);
    expect(errorKindOf('error_busy'), SpeechErrorKind.busy);
    expect(errorKindOf('error_unknown (7)'), SpeechErrorKind.unknown);
  });
}
