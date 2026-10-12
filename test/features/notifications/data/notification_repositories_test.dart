import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:productivity_planner/features/notifications/data/mock/notification_mock_routes.dart';
import 'package:productivity_planner/features/notifications/data/repositories/notification_repositories_impl.dart';
import 'package:productivity_planner/features/notifications/domain/entities/notification_preferences.dart';

import '../../../helpers/fakes.dart';

/// Repositories → real Dio client → mock backend speaking contract §3.2.
void main() {
  late MockApiAdapter adapter;
  late NotificationMockBackend backend;
  late HttpNotificationRemoteDataSource remote;
  late RecordingErrorReporter reporter;

  setUp(() {
    adapter = MockApiAdapter();
    backend = NotificationMockBackend(
      clock: FixedClock(DateTime.utc(2026, 10, 7)),
    )..register(adapter);
    reporter = RecordingErrorReporter();
    final config = HttpClientConfig(
      baseUrl: Uri.parse('https://api.test/v1'),
      ids: SequentialIdGenerator(),
      deviceIds: const FixedDeviceIdProvider('device-9'),
      logger: RecordingLogger(),
      adapter: adapter,
    );
    remote = HttpNotificationRemoteDataSource(
      createApiHttpClient(
        config,
        tokens: FakeTokenProvider(
          token: 'access',
          onRefresh: () => throw StateError('no refresh expected'),
        ),
        retryClient: createPublicHttpClient(config),
      ),
    );
  });

  test('registers the device with the contract body', () async {
    final repository = DeviceRegistrationRepositoryImpl(
      remote: remote,
      deviceIds: const FixedDeviceIdProvider('device-9'),
      device: const FakeDeviceContext(),
      reporter: reporter,
      platform: TargetPlatform.iOS,
    );

    final result = await repository.register(
      pushToken: null,
      remindersEnabled: false,
    );

    expect(result.isOk, isTrue);
    expect(backend.devices['device-9'], {
      'platform': 'ios',
      'push_token': null,
      'locale': 'en-IN',
      'time_zone': 'Asia/Kolkata',
      'reminders_enabled': false,
    });
    expect(adapter.received.single.method, 'PUT');
  });

  test('offline registration is a network failure, not an exception', () async {
    adapter.offline = true;
    final repository = DeviceRegistrationRepositoryImpl(
      remote: remote,
      deviceIds: const FixedDeviceIdProvider(),
      device: const FakeDeviceContext(),
      reporter: reporter,
      platform: TargetPlatform.android,
    );
    final result = await repository.register(
      pushToken: 'token',
      remindersEnabled: true,
    );
    expect(result.isErr, isTrue);
    expect(reporter.errors, isEmpty);
  });

  test('preferences load and save', () async {
    final repository = NotificationPreferencesRepositoryImpl(
      remote: remote,
      reporter: reporter,
    );
    expect(
      (await repository.load()).valueOrNull,
      const NotificationPreferences(),
    );

    final saved = await repository.save(
      const NotificationPreferences(insights: false),
    );
    expect(saved.valueOrNull?.insights, isFalse);
    expect(backend.preferences, {'insights': false, 'weekly_summary': true});
  });
}
