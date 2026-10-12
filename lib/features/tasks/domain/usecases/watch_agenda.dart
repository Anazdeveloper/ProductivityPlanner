import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/clock.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/time_zone_converter.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/home_time_zone.dart';
import 'package:productivity_planner/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_planner/features/tasks/domain/services/work_timer.dart';

final class AgendaRange {
  const AgendaRange({required this.from, required this.to});

  /// A single day.
  AgendaRange.day(LocalDate date) : from = date, to = date;

  final LocalDate from;
  final LocalDate to;
}

/// Occurrences for a date range (Today, Planner), ordered: timed ones by
/// start, then any-time ones by priority and title.
final class WatchAgenda
    implements StreamUseCase<List<AgendaItem>, AgendaRange> {
  const WatchAgenda(this._repository);

  final TaskRepository _repository;

  @override
  Stream<Result<List<AgendaItem>>> call(AgendaRange range) => _repository
      .watchAgenda(from: range.from, to: range.to)
      .map((result) => result.map((items) => [...items]..sort(compareAgenda)));
}

/// Agenda order. Exposed for tests and for lists merged in presentation.
int compareAgenda(AgendaItem a, AgendaItem b) {
  final byDate = a.occurrence.scheduledDate.compareTo(
    b.occurrence.scheduledDate,
  );
  if (byDate != 0) return byDate;
  final startA = a.occurrence.scheduledStart;
  final startB = b.occurrence.scheduledStart;
  if (startA != null && startB != null) {
    final byStart = startA.compareTo(startB);
    if (byStart != 0) return byStart;
  } else if (startA != null) {
    return -1;
  } else if (startB != null) {
    return 1;
  }
  final byPriority = b.task.priority.index.compareTo(a.task.priority.index);
  if (byPriority != 0) return byPriority;
  final byTitle = a.task.title.toLowerCase().compareTo(
    b.task.title.toLowerCase(),
  );
  return byTitle != 0 ? byTitle : a.occurrence.id.compareTo(b.occurrence.id);
}

/// One occurrence (detail screen, notification tap).
final class WatchAgendaItem implements StreamUseCase<AgendaItem?, String> {
  const WatchAgendaItem(this._repository);

  final TaskRepository _repository;

  @override
  Stream<Result<AgendaItem?>> call(String occurrenceId) =>
      _repository.watchAgendaItem(occurrenceId);
}

/// What the person is working on now: the running occurrence, else the
/// most recently paused one (`pickActiveWork`); null when none.
final class WatchActiveWork implements StreamUseCase<AgendaItem?, NoParams> {
  const WatchActiveWork(this._repository);

  final TaskRepository _repository;

  @override
  Stream<Result<AgendaItem?>> call(NoParams params) => _repository
      .watchInProgress()
      .map((result) => result.map(pickActiveWork));
}

final class GetTask implements UseCase<Task, String> {
  const GetTask(this._repository);

  final TaskRepository _repository;

  @override
  Future<Result<Task>> call(String taskId) => _repository.getTask(taskId);
}

/// The zone new tasks are created in and "today" is measured in.
final class GetHomeTimeZone implements UseCase<String, NoParams> {
  const GetHomeTimeZone({
    required HomeTimeZone homeTimeZone,
    required TimeZoneConverter converter,
  }) : _homeTimeZone = homeTimeZone,
       _converter = converter;

  final HomeTimeZone _homeTimeZone;
  final TimeZoneConverter _converter;

  /// Falls back to UTC for a zone this build's tz data does not know.
  @override
  Future<Result<String>> call(NoParams params) async {
    final zone = await _homeTimeZone.current();
    return Ok(_converter.isValidZone(zone) ? zone : 'UTC');
  }
}

/// Today's date in the user's home zone.
final class GetHomeToday implements UseCase<LocalDate, NoParams> {
  const GetHomeToday({
    required HomeTimeZone homeTimeZone,
    required TimeZoneConverter converter,
    required Clock clock,
  }) : _homeTimeZone = homeTimeZone,
       _converter = converter,
       _clock = clock;

  final HomeTimeZone _homeTimeZone;
  final TimeZoneConverter _converter;
  final Clock _clock;

  @override
  Future<Result<LocalDate>> call(NoParams params) async {
    final zone = await _homeTimeZone.current();
    final safeZone = _converter.isValidZone(zone) ? zone : 'UTC';
    return Ok(_converter.localDate(_clock.now(), safeZone));
  }
}
