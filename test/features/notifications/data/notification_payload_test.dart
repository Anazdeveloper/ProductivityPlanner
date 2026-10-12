import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/features/notifications/data/models/notification_payload.dart';
import 'package:productivity_planner/features/notifications/domain/entities/reminder.dart';

void main() {
  test('reminder payloads round-trip', () {
    const payload = ReminderPayload(
      occurrenceId: 'occ-1',
      kind: ReminderKind.snooze,
      fingerprint: 'abc',
    );
    final decoded = NotificationPayload.decode(payload.encode());
    expect(decoded, isA<ReminderPayload>());
    final reminder = decoded as ReminderPayload?;
    expect(reminder?.occurrenceId, 'occ-1');
    expect(reminder?.kind, ReminderKind.snooze);
    expect(reminder?.fingerprint, 'abc');
  });

  test('push payloads keep type and route', () {
    final decoded = NotificationPayload.decode(
      const PushPayload(type: 'insight', route: '/analytics').encode(),
    );
    expect(decoded, isA<PushPayload>());
    final push = decoded as PushPayload?;
    expect(push?.route, '/analytics');
    expect(push?.type, 'insight');
  });

  test('anything else is not ours', () {
    for (final raw in [
      null,
      '',
      'not json',
      '[]',
      '{"v":2,"k":"reminder","o":"x","f":"y"}',
      '{"v":1,"k":"reminder","o":3}',
      '{"v":1,"k":"other"}',
    ]) {
      expect(NotificationPayload.decode(raw), isNull, reason: '$raw');
    }
  });
}
