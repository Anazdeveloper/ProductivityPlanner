import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/http_clients.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';

/// `POST sync/push` and `GET sync/pull`. Throws (Dio errors, or
/// FormatException for a malformed body); the engine maps failures.
abstract interface class SyncRemoteDataSource {
  Future<List<PushResult>> push({
    required String deviceId,
    required List<SyncOp> ops,
  });

  Future<PullPage> pull({required int cursor, required int limit});
}

final class HttpSyncRemoteDataSource implements SyncRemoteDataSource {
  const HttpSyncRemoteDataSource(this._client);

  final ApiHttpClient _client;

  @override
  Future<List<PushResult>> push({
    required String deviceId,
    required List<SyncOp> ops,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      ApiPaths.syncPush,
      // Each op is idempotent by its op_id (contract §4.1). The request's
      // Idempotency-Key comes from the client per request (kept on a
      // transport retry), so a later run is never answered from a stored
      // response that may have left ops unprocessed.
      data: {
        'device_id': deviceId,
        'ops': [for (final op in ops) op.toJson()],
      },
    );
    return parsePushResponse(_body(response.data));
  }

  @override
  Future<PullPage> pull({required int cursor, required int limit}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      ApiPaths.syncPull,
      queryParameters: {'cursor': cursor, 'limit': limit},
    );
    return parsePullResponse(_body(response.data));
  }
}

Map<String, dynamic> _body(Map<String, dynamic>? data) =>
    data ?? (throw const FormatException('Expected a JSON object body'));

const _statuses = {
  'applied': PushStatus.applied,
  'duplicate': PushStatus.duplicate,
  'merged': PushStatus.merged,
  'rejected': PushStatus.rejected,
};

/// Unknown statuses are left out: their ops stay queued and are retried.
List<PushResult> parsePushResponse(Map<String, dynamic> body) {
  final results = body['results'];
  if (results is! List) throw const FormatException('results', 'push');
  return [
    for (final raw in results)
      if (raw is Map && raw['op_id'] is String)
        if (_statuses[raw['status']] case final status?)
          PushResult(
            opId: raw['op_id'] as String,
            status: status,
            version: raw['version'] is int ? raw['version'] as int : null,
            code: switch (raw['problem']) {
              {'code': final String code} => code,
              _ => null,
            },
          ),
  ];
}

PullPage parsePullResponse(Map<String, dynamic> body) {
  final changes = body['changes'];
  final cursor = body['cursor'];
  if (changes is! List || cursor is! int) {
    throw const FormatException('changes/cursor', 'pull');
  }
  return PullPage(
    changes: [
      for (final raw in changes)
        if (raw is Map &&
            raw['entity'] is String &&
            raw['id'] is String &&
            raw['version'] is int)
          SyncChange(
            entity: raw['entity'] as String,
            id: raw['id'] as String,
            version: raw['version'] as int,
            deleted: raw['deleted'] == true,
            data: raw['data'] is Map
                ? Map<String, Object?>.from(raw['data'] as Map)
                : const {},
          ),
    ],
    cursor: cursor,
    hasMore: body['has_more'] == true,
  );
}
