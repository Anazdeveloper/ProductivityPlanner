import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/voice/domain/entities/parsed_task.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/domain/services/speech_to_text_engine.dart';
import 'package:productivity_planner/features/voice/domain/services/task_text_parser.dart';

/// Pipeline step 1: get the microphone and recognizer ready.
final class PrepareSpeech implements UseCase<SpeechAvailability, NoParams> {
  const PrepareSpeech(this._engine);

  final SpeechToTextEngine _engine;

  @override
  Future<Result<SpeechAvailability>> call(NoParams params) async =>
      Ok(await _engine.prepare());
}

/// Pipeline step 2: speech → text, as a live stream of transcripts.
final class ListenForSpeech {
  const ListenForSpeech(this._engine);

  /// The language task sentences are understood in (English at launch).
  static const language = 'en';

  final SpeechToTextEngine _engine;

  Stream<SpeechEvent> call() => _engine.listen(language: language);
}

final class StopListening implements UseCase<Unit, NoParams> {
  const StopListening(this._engine);

  final SpeechToTextEngine _engine;

  @override
  Future<Result<Unit>> call(NoParams params) async {
    await _engine.stop();
    return const Ok(unit);
  }
}

/// Pipeline step 3: text → structured task draft, resolved against the
/// user's today, current time and categories. Step 4 (confirmation) is the
/// task editor; nothing is created here.
final class ParseSpokenTask implements UseCase<ParsedTask, String> {
  const ParseSpokenTask({
    required TaskTextParser parser,
    required GetHomeTimeZone getHomeTimeZone,
    required WatchCategories watchCategories,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _parser = parser,
       _getHomeTimeZone = getHomeTimeZone,
       _watchCategories = watchCategories,
       _converter = converter,
       _clock = clock;

  final TaskTextParser _parser;
  final GetHomeTimeZone _getHomeTimeZone;
  final WatchCategories _watchCategories;
  final TimeZoneConverter _converter;
  final Clock _clock;

  @override
  Future<Result<ParsedTask>> call(String text) async {
    final zone =
        (await _getHomeTimeZone(const NoParams())).valueOrNull ?? 'UTC';
    final categories =
        (await _watchCategories(const NoParams()).first).valueOrNull ??
        const <Category>[];
    final now = _clock.now();
    return await _parser.parse(
      text,
      ParseContext(
        today: _converter.localDate(now, zone),
        now: _converter.localTime(now, zone),
        categories: categories,
        language: ListenForSpeech.language,
      ),
    );
  }
}
