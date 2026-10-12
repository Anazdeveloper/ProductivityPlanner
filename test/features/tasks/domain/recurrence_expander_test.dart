import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/services/recurrence_expander.dart';

/// The server runs the same vector file; both implementations must agree.
const _vectorFile = '../../contracts/vectors/recurrence.json';

RecurrenceRule _rule(Map<String, dynamic> json) => RecurrenceRule(
  frequency: RecurrenceFrequency.values.byName(json['frequency'] as String),
  interval: json['interval'] as int? ?? 1,
  weekdays: (json['weekdays'] as List<dynamic>? ?? const []).cast<int>(),
  monthDay: json['month_day'] as int?,
  until: LocalDate.tryParse(json['until'] as String?),
  count: json['count'] as int?,
);

void main() {
  const expander = RecurrenceExpander();
  final file = File(_vectorFile);

  test('vector file is present', () {
    expect(file.existsSync(), isTrue, reason: 'Run tests from apps/mobile');
  });

  final cases = file.existsSync()
      ? ((jsonDecode(file.readAsStringSync()) as Map<String, dynamic>)['cases']
                as List<dynamic>)
            .cast<Map<String, dynamic>>()
      : const <Map<String, dynamic>>[];

  group('vectors', () {
    for (final c in cases) {
      test(c['name'] as String, () {
        final dates = expander.expand(
          _rule(c['rule'] as Map<String, dynamic>),
          LocalDate.parse(c['start_date'] as String),
          from: LocalDate.parse(c['from'] as String),
          to: LocalDate.parse(c['to'] as String),
        );
        expect(
          dates.map((d) => d.toString()).toList(),
          (c['expected'] as List<dynamic>).cast<String>(),
        );
      });
    }
  });

  test('duplicate weekdays do not produce duplicate dates', () {
    final dates = expander.expand(
      const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [3, 3, 1],
      ),
      LocalDate(2026, 10, 5),
      from: LocalDate(2026, 10, 5),
      to: LocalDate(2026, 10, 11),
    );
    expect(dates, [LocalDate(2026, 10, 5), LocalDate(2026, 10, 7)]);
  });
}
