import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/analytics/domain/entities/execution_record.dart';

/// Execution history, live: emits again whenever an occurrence or work
/// session in range changes, so analytics follow what the person does.
abstract interface class AnalyticsRepository {
  /// Occurrences planned for dates in `[from, to]` (cancelled included;
  /// the calculator ignores them).
  Stream<Result<List<ExecutionRecord>>> watchRecords({
    required LocalDate from,
    required LocalDate to,
  });

  /// One activity's occurrences (every series of [lineageId]) planned for
  /// dates in `[from, to]`.
  Stream<Result<List<ExecutionRecord>>> watchActivity(
    String lineageId, {
    required LocalDate from,
    required LocalDate to,
  });
}
