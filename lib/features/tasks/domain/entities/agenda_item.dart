import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_occurrence.dart';
import 'package:productivity_planner/features/tasks/domain/entities/work_session.dart';

part 'agenda_item.freezed.dart';

/// Everything a list row or detail screen needs about one occurrence.
///
/// Holds no derived status: that depends on the current time, so the
/// presentation layer resolves it on its own ticker with
/// `OccurrenceStatusResolver`.
@freezed
abstract class AgendaItem with _$AgendaItem {
  const factory AgendaItem({
    required TaskOccurrence occurrence,
    required Task task,
    Category? category,

    /// All work sessions of this occurrence, oldest first.
    @Default(<WorkSession>[]) List<WorkSession> sessions,
  }) = _AgendaItem;

  const AgendaItem._();

  WorkSession? get openSession {
    for (final session in sessions) {
      if (session.isOpen) return session;
    }
    return null;
  }

  Duration trackedTime(DateTime now) => totalTracked(sessions, now);
}
