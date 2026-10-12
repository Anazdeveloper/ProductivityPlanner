import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';

void main() {
  const failure = Failure.network();

  group('Result', () {
    test('Ok exposes its value', () {
      const result = Ok<int>(3);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, 3);
      expect(result.failureOrNull, isNull);
    });

    test('Err exposes its failure', () {
      const result = Err<int>(failure);
      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('map transforms Ok and passes Err through', () {
      expect(const Ok<int>(2).map((v) => v * 10), const Ok<int>(20));
      expect(const Err<int>(failure).map((v) => v * 10), const Err<int>(failure));
    });

    test('fold picks the matching branch', () {
      expect(
        const Ok<int>(1).fold(onOk: (v) => 'ok $v', onErr: (_) => 'err'),
        'ok 1',
      );
      expect(
        const Err<int>(failure).fold(onOk: (_) => 'ok', onErr: (_) => 'err'),
        'err',
      );
    });

    test('andThen chains on Ok and short-circuits on Err', () async {
      var secondStepRan = false;
      Future<Result<String>> next(int v) async {
        secondStepRan = true;
        return Ok('value $v');
      }

      expect(await const Ok<int>(5).andThen(next), const Ok('value 5'));
      expect(secondStepRan, isTrue);

      secondStepRan = false;
      expect(await const Err<int>(failure).andThen(next), const Err<String>(failure));
      expect(secondStepRan, isFalse);
    });

    test('failures compare by value (freezed)', () {
      expect(
        const Failure.conflict(code: 'ALREADY_RESOLVED'),
        const Failure.conflict(code: 'ALREADY_RESOLVED'),
      );
    });
  });
}
