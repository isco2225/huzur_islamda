import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:permission_handler/permission_handler.dart' as pck;

void main() {
  group('PermissionState', () {
    test('exposes the four states', () {
      expect(PermissionState.values, [
        PermissionState.requestable,
        PermissionState.granted,
        PermissionState.permanentlyDenied,
        PermissionState.unknown,
      ]);
    });
  });

  group('PermissionStates', () {
    test('defaults every permission to unknown', () {
      final states = PermissionStates();

      expect(states.location, PermissionState.unknown);
      expect(states.notification, PermissionState.unknown);
    });

    test('fromPermission maps each permission to its own state', () {
      final states = PermissionStates(
        location: PermissionState.granted,
        notification: PermissionState.permanentlyDenied,
      );

      expect(
        states.fromPermission(Permission.location),
        PermissionState.granted,
      );
      expect(
        states.fromPermission(Permission.notification),
        PermissionState.permanentlyDenied,
      );
    });
  });

  group('ToPermissionState', () {
    test('maps every permission_handler status', () {
      expect(
        pck.PermissionStatus.denied.toPermissionState(),
        PermissionState.requestable,
      );
      expect(
        pck.PermissionStatus.granted.toPermissionState(),
        PermissionState.granted,
      );
      expect(
        pck.PermissionStatus.limited.toPermissionState(),
        PermissionState.granted,
      );
      expect(
        pck.PermissionStatus.provisional.toPermissionState(),
        PermissionState.granted,
      );
      expect(
        pck.PermissionStatus.permanentlyDenied.toPermissionState(),
        PermissionState.permanentlyDenied,
      );
      expect(
        pck.PermissionStatus.restricted.toPermissionState(),
        PermissionState.permanentlyDenied,
      );
    });

    test('covers every status the package defines', () {
      for (final status in pck.PermissionStatus.values) {
        expect(status.toPermissionState(), isNot(PermissionState.unknown));
      }
    });
  });

  group('GetPermissionStatesUseCase.custom', () {
    test('returns Ok with the states from the custom function', () async {
      final expected = PermissionStates(location: PermissionState.granted);
      final useCase = GetPermissionStatesUseCase.custom(
        ({required int? androidVersionSdkNumber}) async => expected,
      );

      final result = await useCase.get(androidVersionSdkNumber: null);

      expect(result, isA<Ok<PermissionStates>>());
      expect(result.asOk.value, same(expected));
    });

    test('forwards androidVersionSdkNumber to the custom function', () async {
      int? received;
      final useCase = GetPermissionStatesUseCase.custom(({
        required int? androidVersionSdkNumber,
      }) async {
        received = androidVersionSdkNumber;
        return PermissionStates();
      });

      await useCase.get(androidVersionSdkNumber: 33);

      expect(received, 33);
    });

    test('returns Error when the custom function throws an Exception', () async {
      final exception = Exception('platform');
      final useCase = GetPermissionStatesUseCase.custom(
        ({required int? androidVersionSdkNumber}) async => throw exception,
      );

      final result = await useCase.get(androidVersionSdkNumber: null);

      expect(result, isA<Error<PermissionStates>>());
      expect(result.asError.error, same(exception));
    });

    test('does not catch non-Exception errors', () async {
      final useCase = GetPermissionStatesUseCase.custom(
        ({required int? androidVersionSdkNumber}) async =>
            throw StateError('bad'),
      );

      expect(
        () => useCase.get(androidVersionSdkNumber: null),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('RequestPermissionUseCase.custom', () {
    test('returns Ok with the state from the custom function', () async {
      final useCase = RequestPermissionUseCase.custom(
        ({
          required Permission permission,
          required int? androidVersionSdkNumber,
        }) async => PermissionState.granted,
      );

      final result = await useCase.request(
        permission: Permission.notification,
        androidVersionSdkNumber: null,
      );

      expect(result, isA<Ok<PermissionState>>());
      expect(result.asOk.value, PermissionState.granted);
    });

    test('forwards permission and sdk number to the custom function', () async {
      Permission? receivedPermission;
      int? receivedSdk;
      final useCase = RequestPermissionUseCase.custom(({
        required Permission permission,
        required int? androidVersionSdkNumber,
      }) async {
        receivedPermission = permission;
        receivedSdk = androidVersionSdkNumber;
        return PermissionState.requestable;
      });

      await useCase.request(
        permission: Permission.location,
        androidVersionSdkNumber: 31,
      );

      expect(receivedPermission, Permission.location);
      expect(receivedSdk, 31);
    });

    test('returns Error when the custom function throws an Exception', () async {
      final exception = Exception('denied by OS');
      final useCase = RequestPermissionUseCase.custom(
        ({
          required Permission permission,
          required int? androidVersionSdkNumber,
        }) async => throw exception,
      );

      final result = await useCase.request(
        permission: Permission.location,
        androidVersionSdkNumber: null,
      );

      expect(result, isA<Error<PermissionState>>());
      expect(result.asError.error, same(exception));
    });
  });
}
