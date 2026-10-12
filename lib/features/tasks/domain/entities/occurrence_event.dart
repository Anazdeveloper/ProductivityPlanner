import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

part 'occurrence_event.freezed.dart';

/// An entry in an occurrence's history ("postponed from Tue 09:00 to Wed").
@freezed
abstract class OccurrenceEvent with _$OccurrenceEvent {
  const factory OccurrenceEvent({
    required String id,
    required String occurrenceId,
    required OccurrenceTransition type,
    required DateTime occurredAt,

    /// Type-specific details with string/number values, e.g.
    /// `{'from_date': '2026-10-06', 'to_date': '2026-10-07'}`.
    @Default(<String, Object?>{}) Map<String, Object?> data,
  }) = _OccurrenceEvent;
}
