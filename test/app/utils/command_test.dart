import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/utils.dart';

void main() {
  group('Command0', () {
    test('initial state is idle with no result', () {
      final command = Command0<int>(
        () async => const Ok(1),
        debugLabel: 'test',
      );

      expect(command.running.value, isFalse);
      expect(command.error.value, isFalse);
      expect(command.completed.value, isFalse);
      expect(command.result.value, isNull);

      command.dispose();
    });

    test('execute sets running while action is in flight', () async {
      final completer = Completer<Result<int>>();
      final command = Command0<int>(
        () => completer.future,
        debugLabel: 'test',
      );

      final future = command.execute();
      expect(command.running.value, isTrue);
      expect(command.result.value, isNull);

      completer.complete(const Ok(5));
      await future;

      expect(command.running.value, isFalse);
      expect(command.completed.value, isTrue);
      expect(command.error.value, isFalse);
      expect(command.result.value, isA<Ok<int>>());
      expect(command.result.value!.asOk.value, 5);

      command.dispose();
    });

    test('error result sets error flag and clears completed', () async {
      final command = Command0<int>(
        () async => Error(Exception('fail')),
        debugLabel: 'test',
      );

      await command.execute();

      expect(command.error.value, isTrue);
      expect(command.completed.value, isFalse);
      expect(command.result.value, isA<Error<int>>());

      command.dispose();
    });

    test('clearResult resets result, error and completed', () async {
      final command = Command0<int>(
        () async => const Ok(1),
        debugLabel: 'test',
      );

      await command.execute();
      expect(command.completed.value, isTrue);

      command.clearResult();

      expect(command.result.value, isNull);
      expect(command.completed.value, isFalse);
      expect(command.error.value, isFalse);

      command.dispose();
    });

    test('concurrent execute is ignored while running', () async {
      var callCount = 0;
      final completer = Completer<Result<int>>();
      final command = Command0<int>(
        () {
          callCount++;
          return completer.future;
        },
        debugLabel: 'test',
      );

      final first = command.execute();
      final second = command.execute();
      completer.complete(const Ok(1));
      await Future.wait([first, second]);

      expect(callCount, 1);

      command.dispose();
    });

    test('can be executed again after completion', () async {
      var callCount = 0;
      final command = Command0<int>(
        () async => Ok(++callCount),
        debugLabel: 'test',
      );

      await command.execute();
      await command.execute();

      expect(callCount, 2);
      expect(command.result.value!.asOk.value, 2);

      command.dispose();
    });

    test('running is reset even when the action throws', () async {
      final command = Command0<int>(
        () async => throw StateError('unexpected'),
        debugLabel: 'test',
      );

      await expectLater(command.execute(), throwsA(isA<StateError>()));

      expect(command.running.value, isFalse);
      expect(command.result.value, isNull);

      command.dispose();
    });

    test('execute after dispose is a no-op and does not throw', () async {
      var called = false;
      final command = Command0<int>(
        () async {
          called = true;
          return const Ok(1);
        },
        debugLabel: 'test',
      );

      command.dispose();
      await command.execute();

      expect(called, isFalse);
    });

    test('dispose during in-flight action does not throw', () async {
      final completer = Completer<Result<int>>();
      final command = Command0<int>(
        () => completer.future,
        debugLabel: 'test',
      );

      final future = command.execute();
      command.dispose();
      completer.complete(const Ok(1));

      await expectLater(future, completes);
    });

    test('notifies listeners of running transitions in order', () async {
      final transitions = <bool>[];
      final command = Command0<int>(
        () async => const Ok(1),
        debugLabel: 'test',
      );
      command.running.addListener(() => transitions.add(command.running.value));

      await command.execute();

      expect(transitions, [true, false]);

      command.dispose();
    });
  });

  group('Command1', () {
    test('passes the argument to the action', () async {
      String? received;
      final command = Command1<int, String>(
        (arg) async {
          received = arg;
          return Ok(arg.length);
        },
        debugLabel: 'test',
      );

      await command.execute('hello');

      expect(received, 'hello');
      expect(command.result.value!.asOk.value, 5);

      command.dispose();
    });

    test('error result from argumented action sets error flag', () async {
      final command = Command1<int, int>(
        (arg) async =>
            arg < 0 ? Error(Exception('negative')) : Ok(arg),
        debugLabel: 'test',
      );

      await command.execute(-1);
      expect(command.error.value, isTrue);

      await command.execute(3);
      expect(command.error.value, isFalse);
      expect(command.completed.value, isTrue);

      command.dispose();
    });
  });
}
