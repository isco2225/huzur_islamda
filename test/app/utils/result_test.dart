import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';

void main() {
  group('Result', () {
    test('Result.ok creates an Ok holding the value', () {
      final result = Result.ok(42);

      expect(result, isA<Ok<int>>());
      expect(result.asOk.value, 42);
    });

    test('Result.error creates an Error holding the exception', () {
      final exception = Exception('boom');
      final result = Result<int>.error(exception);

      expect(result, isA<Error<int>>());
      expect(result.asError.error, same(exception));
    });

    test('asOk throws when called on an Error', () {
      final result = Result<int>.error(Exception('x'));

      expect(() => result.asOk, throwsA(isA<TypeError>()));
    });

    test('asError throws when called on an Ok', () {
      final result = Result.ok('value');

      expect(() => result.asError, throwsA(isA<TypeError>()));
    });

    test('switch on sealed Result is exhaustive', () {
      String describe(Result<String> r) => switch (r) {
        Ok(value: final v) => 'ok:$v',
        Error(error: final e) => 'error:$e',
      };

      expect(describe(const Ok('a')), 'ok:a');
      expect(
        describe(Error(Exception('b'))),
        'error:Exception: b',
      );
    });

    test('toString is descriptive for Ok and Error', () {
      expect(const Ok<int>(1).toString(), 'Result<int>.ok(1)');
      expect(
        Error<int>(Exception('e')).toString(),
        'Result<int>.error(Exception: e)',
      );
    });

    test('Ok can hold null for nullable type', () {
      final result = Result<String?>.ok(null);

      expect(result, isA<Ok<String?>>());
      expect(result.asOk.value, isNull);
    });
  });
}
