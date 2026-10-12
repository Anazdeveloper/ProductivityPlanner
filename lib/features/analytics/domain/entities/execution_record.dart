import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

part 'execution_record.freezed.dart';

/// What happened to one occurrence: the analytics input.
///
/// A flat read model built from the tasks feature's occurrences and work
/// sessions, so analytics never depends on how tasks are stored. Holds the
/// facts the brief asks to track: scheduled start, actual start, expected
/// and actual duration, completion time and status, postponements.
@freezed
abstract class ExecutionRecord with _$ExecutionRecord {
  const factory ExecutionRecord({
    required String occurrenceId,

    /// Follows one activity across "change from this date" splits.
    required String lineageId,

    /// The series this occurrence belongs to.
    required String taskId,
    required String title,

    /// The series' zone: "today" and "missed" are judged in it.
    required String timeZone,

    /// The date it is (or was last) planned for. A postponed occurrence
    /// counts on its new date.
    required LocalDate date,

    /// Expected duration, copied onto the occurrence when it was created.
    required Duration planned,

    /// The series' expected duration now (may have changed since).
    required Duration seriesPlanned,
    required OccurrenceStatus status,

    /// Time in finished work sessions.
    @Default(Duration.zero) Duration closedSessionTime,

    /// Start of the running work session, if one is running.
    DateTime? openSessionStart,
    Category? category,

    /// UTC; null for an any-time task.
    DateTime? scheduledStart,

    /// When work first started.
    DateTime? actualStart,

    /// Null means not measured (done without a timer), which is not zero.
    Duration? actualDuration,

    /// When it became completed, skipped or cancelled.
    DateTime? resolvedAt,
    @Default(0) int postponeCount,
  }) = _ExecutionRecord;

  const ExecutionRecord._();

  /// Time in work sessions, a running one counted up to [now].
  Duration sessionTime(DateTime now) {
    final open = openSessionStart;
    if (open == null) return closedSessionTime;
    final running = now.difference(open);
    return closedSessionTime + (running.isNegative ? Duration.zero : running);
  }

  /// How late work started compared with the plan (negative = early).
  /// Null for an any-time task or one that was never started.
  Duration? get startDelay {
    final planned = scheduledStart;
    final actual = actualStart;
    if (planned == null || actual == null) return null;
    return actual.difference(planned);
  }
}
