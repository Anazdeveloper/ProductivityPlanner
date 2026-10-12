import 'package:productivity_planner/core/network/api_paths.dart';
import 'package:productivity_planner/core/network/mock/mock_api_adapter.dart';

/// `sync/push` and `sync/pull` (contract §4) for mock builds: one device,
/// so pushes are applied and pulls bring nothing new.
///
/// - Every op is `applied` and bumps its entity's version; an op id seen
///   before is a `duplicate` with the same version (idempotency).
/// - [rejectNext] makes the next op of a type `rejected`, to try the issue
///   flow by hand.
final class SyncMockBackend {
  final Map<String, int> _versions = {};
  final Map<String, int> _seenOps = {};
  final Map<String, String> _rejections = {};
  int _cursor = 0;

  void register(MockApiAdapter adapter) {
    adapter
      ..on('POST', ApiPaths.syncPush, _push)
      ..on(
        'GET',
        ApiPaths.syncPull,
        (_) => MockResponse.json({
          'changes': const <Object>[],
          'cursor': _cursor,
          'has_more': false,
        }),
      );
  }

  /// The next op of [opType] is refused with [code].
  void rejectNext(String opType, {String code = 'ENTITY_DELETED'}) {
    _rejections[opType] = code;
  }

  MockResponse _push(MockRequest request) {
    final body = request.body;
    final ops = body is Map ? body['ops'] : null;
    if (ops is! List) {
      return MockResponse.problem(status: 422, code: 'VALIDATION_FAILED');
    }
    final results = <Map<String, Object?>>[];
    for (final op in ops.whereType<Map<dynamic, dynamic>>()) {
      final opId = op['op_id'];
      final type = op['type'];
      final entityId = op['entity_id'];
      if (opId is! String || type is! String || entityId is! String) continue;
      final seen = _seenOps[opId];
      if (seen != null) {
        results.add(_result(opId, 'duplicate', seen));
        continue;
      }
      final code = _rejections.remove(type);
      if (code != null) {
        results.add({
          'op_id': opId,
          'status': 'rejected',
          'version': null,
          'problem': {'code': code, 'status': 409},
        });
        continue;
      }
      final version = (_versions[entityId] ?? 0) + 1;
      _versions[entityId] = version;
      _seenOps[opId] = version;
      _cursor++;
      results.add(_result(opId, 'applied', version));
    }
    return MockResponse.json({'results': results, 'cursor_hint': _cursor});
  }

  static Map<String, Object?> _result(String opId, String status, int v) => {
    'op_id': opId,
    'status': status,
    'version': v,
    'problem': null,
  };
}
