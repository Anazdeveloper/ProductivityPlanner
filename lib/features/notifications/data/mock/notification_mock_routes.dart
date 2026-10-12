import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';

/// Contract §3.2 endpoints for the mock backend: device upsert and
/// notification preferences, kept in memory.
final class NotificationMockBackend {
  NotificationMockBackend({required Clock clock}) : _clock = clock;

  final Clock _clock;

  /// Device id → last body received.
  final Map<String, Map<String, dynamic>> devices = {};

  Map<String, dynamic> preferences = {'insights': true, 'weekly_summary': true};

  void register(MockApiAdapter adapter) {
    adapter
      ..on('PUT', ApiPaths.device(':id'), _putDevice)
      ..on('GET', ApiPaths.meNotificationPreferences, (_) {
        return MockResponse.json(preferences);
      })
      ..on('PUT', ApiPaths.meNotificationPreferences, _putPreferences);
  }

  MockResponse _putDevice(MockRequest request) {
    final id = request.pathParameters['id'] ?? '';
    final body = request.body;
    if (body is! Map<String, dynamic> ||
        (body['platform'] != 'ios' && body['platform'] != 'android')) {
      return MockResponse.problem(status: 400, code: 'VALIDATION_FAILED');
    }
    devices[id] = body;
    return MockResponse.json({
      'id': id,
      'updated_at': _clock.now().toUtc().toIso8601String(),
    });
  }

  MockResponse _putPreferences(MockRequest request) {
    final body = request.body;
    if (body is! Map<String, dynamic> ||
        body['insights'] is! bool ||
        body['weekly_summary'] is! bool) {
      return MockResponse.problem(status: 400, code: 'VALIDATION_FAILED');
    }
    preferences = {
      'insights': body['insights'],
      'weekly_summary': body['weekly_summary'],
    };
    return MockResponse.json(preferences);
  }
}
