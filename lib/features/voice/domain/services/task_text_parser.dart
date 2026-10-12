import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/features/voice/domain/entities/parsed_task.dart';

/// Natural-language task extraction: a sentence in, a structured draft
/// out. An interface so the on-device rules can later be swapped for an
/// NLP/LLM service (`POST voice/parse`, contract §3.4).
abstract interface class TaskTextParser {
  /// Never fails for text it does not understand: the whole sentence then
  /// becomes the title. Fails only when the provider itself fails (e.g. a
  /// remote parser is unreachable).
  Future<Result<ParsedTask>> parse(String text, ParseContext context);
}
