import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';
import 'package:productivity_planner/features/notifications/domain/services/reminder_planner.dart';
import 'package:productivity_planner/features/tasks/domain/entities/agenda_item.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';

import '../../../helpers/agenda_builders.dart';

AgendaItem _item(
  String id,
  DateTime? start, {
  List<Duration> offsets = const [Duration(minutes: 5)],
  OccurrenceStatus status = OccurrenceStatus.scheduled,
}) {
  final item = agendaItem(
    id: id,
    date: LocalDate(2026, 10, 7),
    title: 'Task $id',
    start: start,
    status: status,
  );
  return item.copyWith(task: item.task.copyWith(reminderOffsets: offsets));
}

void main() {
  const planner = ReminderPlanner();
  final now = DateTime.utc(2026, 10, 7, 9);

  test('one reminder per offset, before the start', () {
    final plan = planner.plan([
      _item(
        'a',
        DateTime.utc(2026, 10, 7, 12),
        offsets: const [Duration(minutes: 5), Duration(hours: 1)],
      ),
    ], now: now);

    expect(plan.map((r) => r.fireAt), [
      DateTime.utc(2026, 10, 7, 11),
      DateTime.utc(2026, 10, 7, 11, 55),
    ]);
    expect(plan.first.kind, ReminderKind.reminder);
    expect(plan.first.taskTitle, 'Task a');
    expect(plan.first.timeZone, 'Asia/Kolkata');
  });

  test('skips reminders whose time has passed, and any-time tasks', () {
    final plan = planner.plan([
      // Starts in 3 minutes: the 5-minute reminder is already late.
      _item('soon', now.add(const Duration(minutes: 3))),
      _item('anytime', null),
    ], now: now);
    expect(plan, isEmpty);
  });

  test('only occurrences that have not started or been resolved', () {
    final start = DateTime.utc(2026, 10, 7, 12);
    final plan = planner.plan([
      _item('done', start, status: OccurrenceStatus.completed),
      _item('running', start, status: OccurrenceStatus.inProgress),
      _item('skipped', start, status: OccurrenceStatus.skipped),
      _item('todo', start),
    ], now: now);
    expect(plan.map((r) => r.occurrenceId), ['todo']);
  });

  test('keeps the earliest reminders up to the cap', () {
    const small = ReminderPlanner(maxPending: 2);
    final plan = small.plan([
      _item('late', DateTime.utc(2026, 10, 9, 12)),
      _item('early', DateTime.utc(2026, 10, 7, 12)),
      _item('middle', DateTime.utc(2026, 10, 8, 12)),
    ], now: now);
    expect(plan.map((r) => r.occurrenceId), ['early', 'middle']);
  });

  test('ids are stable and differ per offset and kind', () {
    final id = reminderNotificationId('occ', ReminderKind.reminder);
    expect(reminderNotificationId('occ', ReminderKind.reminder), id);
    expect(
      reminderNotificationId(
        'occ',
        ReminderKind.reminder,
        offset: const Duration(minutes: 10),
      ),
      isNot(id),
    );
    expect(reminderNotificationId('occ', ReminderKind.snooze), isNot(id));
    expect(id, inInclusiveRange(0, 0x7fffffff));
  });

  test('the fingerprint changes when the time or title changes', () {
    final request = planner.plan([
      _item('a', DateTime.utc(2026, 10, 7, 12)),
    ], now: now).single;
    expect(
      request.copyWith(taskTitle: 'Renamed').fingerprint,
      isNot(request.fingerprint),
    );
    expect(
      request.copyWith(fireAt: request.fireAt.add(const Duration(minutes: 1)))
          .fingerprint,
      isNot(request.fingerprint),
    );
    expect(request.copyWith().fingerprint, request.fingerprint);
  });

  test('stableHash is FNV-1a (31-bit)', () {
    // FNV-1a("a") = 0xe40c292c, masked to 31 bits.
    expect(stableHash('a'), 0xe40c292c & 0x7fffffff);
  });
}
