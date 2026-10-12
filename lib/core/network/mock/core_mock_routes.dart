import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/time/clock.dart';

/// Mock responses for core endpoints, shaped per `contracts/api/v1.md` §6.
/// Features add their own `register<Feature>MockRoutes` in later phases.
void registerCoreMockRoutes(MockApiAdapter adapter, {required Clock clock}) {
  adapter.on(
    'GET',
    'config',
    (_) => MockResponse.json({
      'min_supported_app_version': {'ios': '0.1.0', 'android': '0.1.0'},
      'feature_flags': {'voice_capture': true},
      'server_time': clock.now().toIso8601String(),
    }),
  );
}
