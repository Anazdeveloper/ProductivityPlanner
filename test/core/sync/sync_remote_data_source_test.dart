import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/sync/sync_models.dart';
import 'package:productivity_planner/core/sync/sync_remote_data_source.dart';

void main() {
  group('parsePushResponse', () {
    test('reads statuses, versions and problem codes', () {
      final results = parsePushResponse({
        'results': [
          {'op_id': 'a', 'status': 'applied', 'version': 4, 'problem': null},
          {'op_id': 'b', 'status': 'duplicate', 'version': 2},
          {
            'op_id': 'c',
            'status': 'rejected',
            'version': null,
            'problem': {'code': 'ENTITY_DELETED', 'status': 409},
          },
        ],
        'cursor_hint': 9,
      });

      expect(results.map((r) => r.status), [
        PushStatus.applied,
        PushStatus.duplicate,
        PushStatus.rejected,
      ]);
      expect(results.first.version, 4);
      expect(results.last.code, 'ENTITY_DELETED');
    });

    test('leaves out unknown statuses and malformed entries', () {
      final results = parsePushResponse({
        'results': [
          {'op_id': 'a', 'status': 'postponed'},
          {'status': 'applied'},
          'junk',
          {'op_id': 'b', 'status': 'merged', 'version': 'x'},
        ],
      });
      expect(results.single.opId, 'b');
      expect(results.single.version, isNull);
    });

    test('a body without results is malformed', () {
      expect(() => parsePushResponse({}), throwsFormatException);
    });
  });

  group('parsePullResponse', () {
    test('reads changes, cursor and has_more', () {
      final page = parsePullResponse({
        'changes': [
          {
            'entity': 'series',
            'id': 's1',
            'version': 3,
            'deleted': false,
            'data': {'title': 'Run'},
          },
          {'entity': 'category', 'id': 'c1', 'version': 2, 'deleted': true},
          {'entity': 'series', 'id': 's2'},
        ],
        'cursor': 18240,
        'has_more': true,
      });

      expect(page.cursor, 18240);
      expect(page.hasMore, isTrue);
      expect(page.changes, hasLength(2));
      expect(page.changes.first.data['title'], 'Run');
      expect(page.changes.last.deleted, isTrue);
      expect(page.changes.last.data, isEmpty);
    });

    test('a missing cursor is malformed', () {
      expect(
        () => parsePullResponse({'changes': <Object>[]}),
        throwsFormatException,
      );
    });
  });
}
