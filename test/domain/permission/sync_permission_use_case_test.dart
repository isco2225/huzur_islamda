import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

/// [NotificationService]'s constructor is channel-free, so a subclass can
/// stub the single method [SyncPermissionUseCase] depends on.
class _StubNotificationService extends NotificationService {
  Result<bool> checkResult = const Ok(true);
  int checkCalls = 0;

  @override
  Future<Result<bool>> checkPermissionStatus() async {
    checkCalls++;
    return checkResult;
  }
}

void main() {
  late FakeAppRepository appRepository;
  late _StubNotificationService notificationService;
  late PermissionStates states;
  late Object? getError;

  SyncPermissionUseCase build() {
    return SyncPermissionUseCase(
      getPermissionStatesUseCase: GetPermissionStatesUseCase.custom(({
        required int? androidVersionSdkNumber,
      }) async {
        if (getError != null) {
          // ignore: only_throw_errors
          throw getError!;
        }
        return states;
      }),
      requestPermissionUseCase: RequestPermissionUseCase.custom(
        ({
          required Permission permission,
          required int? androidVersionSdkNumber,
        }) async => PermissionState.granted,
      ),
      appRepository: appRepository,
      notificationService: notificationService,
    );
  }

  setUp(() {
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(isNotificationsEnabled: true),
    );
    notificationService = _StubNotificationService();
    states = PermissionStates(notification: PermissionState.granted);
    getError = null;
  });

  group('SyncPermissionUseCase.syncNotificationPermissionState (non-iOS)', () {
    // These tests exercise the permission_handler branch, which is what runs
    // on the macOS/Linux test host. They are skipped on iOS where the
    // flutter_local_notifications branch would take over.
    final skipOnIos = Platform.isIOS ? 'non-iOS branch only' : null;

    test('does not touch preferences when the permission is granted', () async {
      final result = await build().syncNotificationPermissionState();

      expect(result, isA<Ok<void>>());
      expect(appRepository.calls, isEmpty);
      expect(notificationService.checkCalls, 0);
    }, skip: skipOnIos);

    test('disables notifications in preferences when not granted', () async {
      states = PermissionStates(notification: PermissionState.requestable);

      final result = await build().syncNotificationPermissionState();

      expect(result, isA<Ok<void>>());
      expect(appRepository.calls, ['updateIsNotificationsEnabled(false)']);
      expect(
        appRepository.appPreferencesNotifier.value.isNotificationsEnabled,
        isFalse,
      );
    }, skip: skipOnIos);

    test('treats permanentlyDenied as not granted', () async {
      states = PermissionStates(
        notification: PermissionState.permanentlyDenied,
      );

      await build().syncNotificationPermissionState();

      expect(appRepository.calls, ['updateIsNotificationsEnabled(false)']);
    }, skip: skipOnIos);

    test('leaves preferences alone when not granted but already disabled', () async {
      states = PermissionStates(notification: PermissionState.requestable);
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: false,
      );

      final result = await build().syncNotificationPermissionState();

      expect(result, isA<Ok<void>>());
      expect(appRepository.calls, isEmpty);
    }, skip: skipOnIos);

    test('propagates an update failure', () async {
      states = PermissionStates(notification: PermissionState.requestable);
      final exception = Exception('prefs');
      appRepository.updateIsNotificationsEnabledResult = Error(exception);

      final result = await build().syncNotificationPermissionState();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    }, skip: skipOnIos);

    test('propagates a failure to read permission states', () async {
      final exception = Exception('permission_handler');
      getError = exception;

      final result = await build().syncNotificationPermissionState();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
      expect(appRepository.calls, isEmpty);
    }, skip: skipOnIos);

    test('wraps a non-Exception error thrown while reading states', () async {
      getError = StateError('bad');

      final result = await build().syncNotificationPermissionState();

      expect(result, isA<Error<void>>());
      expect(
        result.asError.error.toString(),
        contains('Failed to sync notification permission state'),
      );
    }, skip: skipOnIos);
  });
}
