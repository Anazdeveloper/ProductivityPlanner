import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/core/timezone/tz_time_zone_converter.dart';

/// The server runs the same vector file.
const _vectorFile = '../../contracts/vectors/zone_resolution.json';

void main() {
  final converter = TzTimeZoneConverter();
  final file = File(_vectorFile);

  test('vector file is present', () {
    expect(file.existsSync(), isTrue, reason: 'Run tests from apps/mobile');
  });

  final vectors = file.existsSync()
      ? jsonDecode(file.readAsStringSync()) as Map<String, dynamic>
      : const <String, dynamic>{};

  group('toUtc', () {
    for (final v in (vectors['to_utc'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()) {
      test('${v['date']} ${v['time']} ${v['zone']} (${v['note']})', () {
        final utc = converter.toUtc(
          LocalDate.parse(v['date'] as String),
          LocalTime.parse(v['time'] as String),
          v['zone'] as String,
        );
        expect(utc.isUtc, isTrue);
        expect(utc, DateTime.parse(v['utc'] as String));
      });
    }
  });

  group('localDate', () {
    for (final v in (vectors['local_date'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()) {
      test('${v['utc']} in ${v['zone']}', () {
        expect(
          converter.localDate(
            DateTime.parse(v['utc'] as String),
            v['zone'] as String,
          ),
          LocalDate.parse(v['date'] as String),
        );
      });
    }
  });

  group('localTime', () {
    for (final v in (vectors['local_time'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()) {
      test('${v['utc']} in ${v['zone']}', () {
        expect(
          converter
              .localTime(DateTime.parse(v['utc'] as String), v['zone'] as String)
              .toString(),
          v['time'],
        );
      });
    }
  });

  test('isValidZone', () {
    expect(converter.isValidZone('Asia/Kolkata'), isTrue);
    expect(converter.isValidZone('UTC'), isTrue);
    expect(converter.isValidZone('Mars/Olympus_Mons'), isFalse);
  });

  test('toUtc rejects an unknown zone', () {
    expect(
      () => converter.toUtc(LocalDate(2026, 10, 7), LocalTime(9, 0), 'Nope/X'),
      throwsArgumentError,
    );
  });
}
