import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/features/notifications/domain/entities/push_message.dart';
import 'package:productivity_planner/features/notifications/domain/services/push_message_router.dart';

void main() {
  const router = PushMessageRouter(
    defaults: {
      PushMessageType.account: '/settings',
      PushMessageType.subscription: '/subscription',
      PushMessageType.insight: '/analytics',
    },
  );

  test('parses the contract data map', () {
    final message = PushMessage.fromData(
      {'type': 'insight', 'route': '/analytics/activities/x', 'insight_id': 'i'},
      title: 'You are on a roll',
    );
    expect(message.type, PushMessageType.insight);
    expect(message.route, '/analytics/activities/x');
    expect(message.title, 'You are on a roll');
    expect(PushMessage.fromData({'type': 'new-thing'}).type,
        PushMessageType.unknown);
    expect(PushMessage.fromData({'route': 42}).route, isNull);
  });

  test('uses a safe route, else the type default', () {
    expect(
      router.locationFor(
        const PushMessage(type: PushMessageType.insight, route: '/today'),
      ),
      '/today',
    );
    for (final unsafe in [
      'https://evil.example/x',
      '//evil.example',
      'today',
      'javascript:alert(1)',
    ]) {
      expect(
        router.locationFor(
          PushMessage(type: PushMessageType.subscription, route: unsafe),
        ),
        '/subscription',
        reason: unsafe,
      );
    }
  });

  test('sync and unknown pushes never navigate', () {
    expect(
      router.locationFor(
        const PushMessage(type: PushMessageType.sync, route: '/today'),
      ),
      isNull,
    );
    expect(
      router.locationFor(const PushMessage(type: PushMessageType.unknown)),
      isNull,
    );
  });
}
