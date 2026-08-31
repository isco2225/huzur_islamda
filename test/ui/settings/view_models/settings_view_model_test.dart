import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late FakeAppRepository appRepository;
  late FakePrayerRepository prayerRepository;
  late FakeNotificationRepository notificationRepository;
  late FakeUserRepository userRepository;
  late StubNotificationService notificationService;
  late PermissionStates permissionStates;
  late Object? getStatesError;
  late PermissionState requestedState;
  late int requestCalls;
  late SettingsViewModel viewModel;

  // `toggleNotifications` branches on `Platform.isIOS`; the test host is
  // macOS/Linux so these tests exercise the permission_handler (Android)
  // path and are skipped if ever run on iOS.
  final skipOnIos = Platform.isIOS ? 'non-iOS branch only' : null;

  SettingsViewModel build() {
    return SettingsViewModel(
      appRepository: appRepository,
      requestPermissionUseCase: RequestPermissionUseCase.custom(({
        required Permission permission,
        required int? androidVersionSdkNumber,
      }) async {
        requestCalls++;
        return requestedState;
      }),
      getPermissionStatesUseCase: GetPermissionStatesUseCase.custom(({
        required int? androidVersionSdkNumber,
      }) async {
        if (getStatesError != null) {
          // ignore: only_throw_errors
          throw getStatesError!;
        }
        return permissionStates;
      }),
      schedulePrayerNotificationsUseCase: SchedulePrayerNotificationsUseCase(
        prayerRepository: prayerRepository,
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
      notificationService: notificationService,
    );
  }

  setUp(() {
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(
        isNotificationsEnabled: false,
        isVibrationEnabled: true,
      ),
    );
    prayerRepository = FakePrayerRepository()
      ..getPrayerTimesLocallyResult = Ok(Fixtures.prayer(days: 7));
    notificationRepository = FakeNotificationRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    notificationService = StubNotificationService();
    permissionStates = PermissionStates(notification: PermissionState.granted);
    getStatesError = null;
    requestedState = PermissionState.granted;
    requestCalls = 0;
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('state notifiers are seeded from the app preferences', () {
    expect(viewModel.isNotificationsEnabled.value, isFalse);
    expect(viewModel.isVibrationEnabled.value, isTrue);
    expect(viewModel.showOpenSettingsDialog.value, isFalse);
  });

  group('toggleVibration', () {
    test('Ok updates the notifier and the repository', () async {
      await viewModel.toggleVibration.execute(false);

      expect(appRepository.calls, ['updateIsVibrationEnabled(false)']);
      expect(appRepository.appPreferencesNotifier.value.isVibrationEnabled, isFalse);
      expect(viewModel.isVibrationEnabled.value, isFalse);
      expect(viewModel.toggleVibration.completed.value, isTrue);
    });

    test('Error keeps the notifier and returns a Turkish message', () async {
      appRepository.updateIsVibrationEnabledResult = Error<void>(Exception('prefs'));

      await viewModel.toggleVibration.execute(false);

      expect(viewModel.isVibrationEnabled.value, isTrue);
      expect(viewModel.toggleVibration.error.value, isTrue);
      expect(
        viewModel.toggleVibration.result.value!.asError.error.toString(),
        contains('Titreşim ayarı güncellenemedi'),
      );
    });
  });

  group('toggleNotifications on (non-iOS path)', () {
    test(
      'granted permission: updates the repository to true and schedules the week',
      () async {
        await viewModel.toggleNotifications.execute(true);

        expect(viewModel.toggleNotifications.completed.value, isTrue);
        expect(viewModel.isNotificationsEnabled.value, isTrue);
        expect(appRepository.calls, ['updateIsNotificationsEnabled(true)']);
        expect(appRepository.appPreferencesNotifier.value.isNotificationsEnabled, isTrue);
        expect(notificationRepository.calls, contains('cancelAllPrayerNotifications()'));
        expect(notificationRepository.scheduledPrayerNotifications, isNotEmpty);
        expect(requestCalls, 0);
        expect(viewModel.showOpenSettingsDialog.value, isFalse);
      },
      skip: skipOnIos,
    );

    test(
      'permanentlyDenied: shows the settings dialog, reverts the notifier and errors',
      () async {
        permissionStates = PermissionStates(
          notification: PermissionState.permanentlyDenied,
        );

        await viewModel.toggleNotifications.execute(true);

        expect(viewModel.toggleNotifications.error.value, isTrue);
        expect(
          viewModel.toggleNotifications.result.value!.asError.error.toString(),
          contains('kalıcı olarak reddedilmiş'),
        );
        expect(viewModel.showOpenSettingsDialog.value, isTrue);
        expect(viewModel.isNotificationsEnabled.value, isFalse);
        expect(appRepository.calls, isEmpty);
        expect(notificationRepository.calls, isEmpty);
      },
      skip: skipOnIos,
    );

    test(
      'requestable: requests through permission_handler and proceeds when granted',
      () async {
        permissionStates = PermissionStates(notification: PermissionState.requestable);

        await viewModel.toggleNotifications.execute(true);

        expect(requestCalls, 1);
        expect(viewModel.toggleNotifications.completed.value, isTrue);
        expect(appRepository.calls, ['updateIsNotificationsEnabled(true)']);
        expect(notificationService.requestPermissionCalls, 0);
      },
      skip: skipOnIos,
    );

    test(
      'requestable but denied on request: errors and reverts the notifier',
      () async {
        permissionStates = PermissionStates(notification: PermissionState.requestable);
        requestedState = PermissionState.requestable;

        await viewModel.toggleNotifications.execute(true);

        expect(viewModel.toggleNotifications.error.value, isTrue);
        expect(
          viewModel.toggleNotifications.result.value!.asError.error.toString(),
          contains('Bildirim izni verilmedi'),
        );
        expect(viewModel.isNotificationsEnabled.value, isFalse);
        expect(appRepository.calls, isEmpty);
      },
      skip: skipOnIos,
    );

    test('failure to read permission states errors without touching prefs', () async {
      getStatesError = Exception('permission_handler');

      await viewModel.toggleNotifications.execute(true);

      expect(viewModel.toggleNotifications.error.value, isTrue);
      expect(
        viewModel.toggleNotifications.result.value!.asError.error.toString(),
        contains('Bildirim izni durumu kontrol edilemedi'),
      );
      expect(viewModel.isNotificationsEnabled.value, isFalse);
      expect(appRepository.calls, isEmpty);
    }, skip: skipOnIos);

    test('a repository failure reverts the notifier and propagates', () async {
      final exception = Exception('prefs');
      appRepository.updateIsNotificationsEnabledResult = Error<void>(exception);

      await viewModel.toggleNotifications.execute(true);

      expect(viewModel.toggleNotifications.error.value, isTrue);
      expect(viewModel.toggleNotifications.result.value!.asError.error, same(exception));
      expect(viewModel.isNotificationsEnabled.value, isFalse);
    }, skip: skipOnIos);
  });

  group('toggleNotifications off', () {
    setUp(() {
      viewModel.dispose();
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: true,
      );
      viewModel = build();
    });

    test('updates the repository to false and cancels all prayer notifications', () async {
      await viewModel.toggleNotifications.execute(false);

      expect(viewModel.toggleNotifications.completed.value, isTrue);
      expect(viewModel.isNotificationsEnabled.value, isFalse);
      expect(appRepository.calls, ['updateIsNotificationsEnabled(false)']);
      expect(notificationRepository.calls, ['cancelAllPrayerNotifications()']);
      expect(notificationRepository.scheduledPrayerNotifications, isEmpty);
      expect(requestCalls, 0);
    });

    test('a repository failure reverts the notifier to true', () async {
      appRepository.updateIsNotificationsEnabledResult = Error<void>(Exception('prefs'));

      await viewModel.toggleNotifications.execute(false);

      expect(viewModel.toggleNotifications.error.value, isTrue);
      expect(viewModel.isNotificationsEnabled.value, isTrue);
      expect(notificationRepository.calls, isEmpty);
    });
  });

  group('checkAndSyncPermissionStatus', () {
    test('enables the preference and schedules when granted but disabled', () async {
      await viewModel.checkAndSyncPermissionStatus();

      expect(appRepository.calls, ['updateIsNotificationsEnabled(true)']);
      expect(notificationRepository.calls, contains('cancelAllPrayerNotifications()'));
    });

    test('leaves the preference alone when the permission is not granted', () async {
      permissionStates = PermissionStates(notification: PermissionState.requestable);

      await viewModel.checkAndSyncPermissionStatus();

      expect(appRepository.calls, isEmpty);
      expect(notificationRepository.calls, isEmpty);
    });

    test('does nothing when the preference is already enabled', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: true,
      );

      await viewModel.checkAndSyncPermissionStatus();

      expect(appRepository.calls, isEmpty);
    });

    test('swallows a failure to read permission states', () async {
      getStatesError = Exception('permission_handler');

      await expectLater(viewModel.checkAndSyncPermissionStatus(), completes);
      expect(appRepository.calls, isEmpty);
    });
  });
}
