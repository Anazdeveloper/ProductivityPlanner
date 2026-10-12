import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';

part 'parsed_task.freezed.dart';

/// The structured task a sentence describes (the brief's extraction
/// output: title, date, startTime, expectedDuration, recurrence,
/// category). Every field is optional: only what was understood is set.
@freezed
abstract class ParsedTask with _$ParsedTask {
  const factory ParsedTask({
    /// The sentence it was parsed from.
    required String text,

    /// The date relative words ("tomorrow") were resolved against.
    required LocalDate today,
    String? title,
    LocalDate? date,
    LocalTime? startTime,

    /// "Any time" was said explicitly ("sometime tomorrow").
    @Default(false) bool anyTime,
    Duration? expectedDuration,
    RecurrenceRule? recurrence,
    Category? category,
  }) = _ParsedTask;

  const ParsedTask._();

  /// Something besides the title was understood.
  bool get hasDetails =>
      date != null ||
      startTime != null ||
      anyTime ||
      expectedDuration != null ||
      recurrence != null ||
      category != null;

  TaskPrefill toPrefill() => TaskPrefill(
    title: title,
    date: date,
    time: startTime,
    anyTime: anyTime,
    duration: expectedDuration,
    recurrence: recurrence,
    categoryId: category?.id,
    originText: text,
  );
}

/// What a parser needs to resolve relative words ("tomorrow", "in an
/// hour", "work").
@freezed
abstract class ParseContext with _$ParseContext {
  const factory ParseContext({
    /// Today and the current time in the user's home zone.
    required LocalDate today,
    required LocalTime now,

    /// The user's categories, matched by name.
    @Default(<Category>[]) List<Category> categories,

    /// BCP 47 tag of the language spoken (the parser may not support it).
    @Default('en') String language,
  }) = _ParseContext;
}
