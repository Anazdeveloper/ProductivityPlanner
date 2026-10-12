import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/logging/log_redactor.dart';

void main() {
  test('redacts sensitive keys regardless of case and dash/underscore', () {
    final redacted = redactLogContext({
      'Authorization': 'Bearer abc',
      'refresh-token': 'r1',
      'title': 'Study Flutter',
      'occurrence_id': 'o1',
      'status': 409,
    });
    expect(redacted, {
      'Authorization': '[redacted]',
      'refresh-token': '[redacted]',
      'title': '[redacted]',
      'occurrence_id': 'o1',
      'status': 409,
    });
  });

  test('redacts nested maps', () {
    final redacted = redactLogContext({
      'payload': <String, Object?>{'notes': 'private', 'count': 2},
    });
    expect(redacted, {
      'payload': {'notes': '[redacted]', 'count': 2},
    });
  });
}
