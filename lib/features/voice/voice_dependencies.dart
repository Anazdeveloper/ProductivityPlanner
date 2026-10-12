import 'package:get_it/get_it.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/categories.dart';
import 'package:productivity_planner/features/tasks/domain/usecases/watch_agenda.dart';
import 'package:productivity_planner/features/voice/data/device_speech_to_text_engine.dart';
import 'package:productivity_planner/features/voice/data/english_task_parser.dart';
import 'package:productivity_planner/features/voice/domain/services/speech_to_text_engine.dart';
import 'package:productivity_planner/features/voice/domain/services/task_text_parser.dart';
import 'package:productivity_planner/features/voice/domain/usecases/voice_usecases.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';

/// Voice task creation. The speech engine and the parser are registered
/// by interface: swapping the provider (a cloud recognizer, an NLP/LLM
/// parser behind `POST voice/parse`) is a change here only.
void registerVoiceDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<SpeechToTextEngine>(DeviceSpeechToTextEngine.new)
    ..registerLazySingleton<TaskTextParser>(EnglishTaskTextParser.new)
    ..registerLazySingleton(() => PrepareSpeech(getIt<SpeechToTextEngine>()))
    ..registerLazySingleton(
      () => ListenForSpeech(getIt<SpeechToTextEngine>()),
    )
    ..registerLazySingleton(() => StopListening(getIt<SpeechToTextEngine>()))
    ..registerLazySingleton(
      () => ParseSpokenTask(
        parser: getIt<TaskTextParser>(),
        getHomeTimeZone: getIt<GetHomeTimeZone>(),
        watchCategories: getIt<WatchCategories>(),
        converter: getIt<TimeZoneConverter>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerFactory(
      () => VoiceCaptureBloc(
        prepareSpeech: getIt<PrepareSpeech>(),
        listenForSpeech: getIt<ListenForSpeech>(),
        stopListening: getIt<StopListening>(),
        parseSpokenTask: getIt<ParseSpokenTask>(),
      ),
    );
}
