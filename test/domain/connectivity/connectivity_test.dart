import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ConnectivityEnum', () {
    test('exposes wifi, mobile and none', () {
      expect(ConnectivityEnum.values, [
        ConnectivityEnum.wifi,
        ConnectivityEnum.mobile,
        ConnectivityEnum.none,
      ]);
    });
  });

  group('ConnectivityException', () {
    test('subclasses are const and implement Exception', () {
      const noConnection = ConnectivityNoConnection();
      const unknown = ConnectivityUnknown();

      expect(noConnection, isA<Exception>());
      expect(unknown, isA<Exception>());
      expect(noConnection, isA<ConnectivityException>());
      expect(
        identical(const ConnectivityNoConnection(), noConnection),
        isTrue,
      );
      expect(noConnection, isNot(isA<ConnectivityUnknown>()));
    });
  });

  group('ConnectivityUseCase', () {
    test('constructor is channel-free under flutter test', () {
      // The base class builds a connectivity_plus `Connectivity()` instance
      // eagerly; instantiating it must not require a platform channel.
      expect(ConnectivityUseCase.new, returnsNormally);
    });
  });

  group('FakeConnectivityUseCase', () {
    test('returns the configured type without touching the platform', () async {
      final fake = FakeConnectivityUseCase(type: ConnectivityEnum.mobile);

      final result = await fake.connectionType();

      expect(result, isA<Ok<ConnectivityEnum>>());
      expect(result.asOk.value, ConnectivityEnum.mobile);
      expect(fake.calls, ['connectionType()']);
    });

    test('can be forced to return an error', () async {
      final fake = FakeConnectivityUseCase()
        ..connectionTypeResult = const Error(ConnectivityUnknown());

      final result = await fake.connectionType();

      expect(result, isA<Error<ConnectivityEnum>>());
      expect(result.asError.error, isA<ConnectivityUnknown>());
    });
  });
}
