import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/ids/id_generator.dart';

/// The server must produce the same ids; both run this vector file.
const _vectorFile = '../../contracts/vectors/occurrence_ids.json';

void main() {
  group('occurrenceIdFor', () {
    final file = File(_vectorFile);

    test('vector file is present', () {
      expect(file.existsSync(), isTrue, reason: 'Run tests from apps/mobile');
    });

    final cases = file.existsSync()
        ? ((jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['cases']
                  as List<dynamic>)
              .cast<Map<String, dynamic>>()
        : const <Map<String, dynamic>>[];

    for (final vector in cases) {
      final seriesId = vector['series_id'] as String;
      final localDate = vector['local_date'] as String;
      test('$seriesId on $localDate', () {
        expect(
          occurrenceIdFor(
            seriesId: seriesId,
            originalLocalDate: DateTime.parse(localDate),
          ),
          vector['occurrence_id'],
        );
      });
    }

    test('ignores the time of day: only the calendar date counts', () {
      const seriesId = '0192a1f0-7c3e-7d4a-9b2e-3f5c8d1e2a40';
      expect(
        occurrenceIdFor(
          seriesId: seriesId,
          originalLocalDate: DateTime(2026, 10, 6, 23, 59),
        ),
        occurrenceIdFor(
          seriesId: seriesId,
          originalLocalDate: DateTime(2026, 10, 6),
        ),
      );
    });

    test('rejects a series id that is not a UUID', () {
      expect(
        () => occurrenceIdFor(
          seriesId: 'not-a-uuid',
          originalLocalDate: DateTime(2026, 10, 6),
        ),
        throwsArgumentError,
      );
    });
  });

  test('UuidV7IdGenerator produces distinct version-7 UUIDs', () {
    const ids = UuidV7IdGenerator();
    final a = ids.newId();
    final b = ids.newId();
    expect(a, isNot(b));
    // Version nibble is the first character of the third group.
    expect(a.split('-')[2][0], '7');
  });

  test('formatLocalDate pads year, month and day', () {
    expect(formatLocalDate(DateTime(987, 3, 4)), '0987-03-04');
  });
}
