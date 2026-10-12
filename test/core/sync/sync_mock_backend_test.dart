import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';
import 'package:productivity_planner/core/sync/sync_mock_backend.dart';

void main() {
  late Dio dio;
  late SyncMockBackend backend;

  setUp(() {
    final adapter = MockApiAdapter();
    backend = SyncMockBackend()..register(adapter);
    dio = Dio(BaseOptions(baseUrl: 'https://api.test/v1/'))
      ..httpClientAdapter = adapter;
  });

  Future<List<Map<String, dynamic>>> push(List<String> opIds) async {
    final response = await dio.post<Map<String, dynamic>>(
      'sync/push',
      data: {
        'device_id': 'd',
        'ops': [
          for (final id in opIds)
            {'op_id': id, 'type': 'series.update', 'entity_id': 's1'},
        ],
      },
    );
    final body = response.data ?? const <String, dynamic>{};
    return (body['results'] as List).cast<Map<String, dynamic>>();
  }

  test('applies ops, bumping versions; a replayed op is a duplicate', () async {
    final first = await push(['a', 'b']);
    expect(first.map((r) => r['version']), [1, 2]);

    final replay = await push(['b']);
    expect(replay.single['status'], 'duplicate');
    expect(replay.single['version'], 2);
  });

  test('rejectNext refuses the next op of that type', () async {
    backend.rejectNext('series.update', code: 'STALE_VERSION');
    final results = await push(['a', 'b']);
    expect(results.first['status'], 'rejected');
    expect((results.first['problem'] as Map)['code'], 'STALE_VERSION');
    expect(results.last['status'], 'applied');
  });

  test('pull has nothing new', () async {
    final response = await dio.get<Map<String, dynamic>>(
      'sync/pull',
      queryParameters: {'cursor': 0, 'limit': 500},
    );
    expect(response.data?['changes'], isEmpty);
    expect(response.data?['has_more'], isFalse);
  });
}
