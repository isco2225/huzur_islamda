import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/app.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

/// Builds [AppViewModel] with the REAL use cases wired over fakes. Only the
/// platform edges (AdMob, local notifications, permission_handler) are
/// stubbed.
void main() {
  late FakeAppRepository appRepository;
  late FakeAuthRepository authRepository;
  late FakeUserRepository userRepository;
  late FakeHiveRepository hiveRepository;
  late FakePostRepository postRepository;
  late FakeDhikrRepository dhikrRepository;
  late FakePrayerRepository prayerRepository;
  late FakeNotificationRepository notificationRepository;
  late FakePurchaseRepository purchaseRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late RecordingAdMobService adMobService;
  late StubNotificationService notificationService;
  late PermissionStates permissionStates;
  late AppViewModel viewModel;

  // `SyncPermissionUseCase` consults flutter_local_notifications on iOS; the
  // permission_handler branch is what runs on the macOS/Linux test host.
  final skipOnIos = Platform.isIOS ? 'non-iOS branch only' : null;

  AppViewModel build() {
    return AppViewModel(
      appRepository: appRepository,
      authRepository: authRepository,
      userRepository: userRepository,
      hiveRepository: hiveRepository,
      postRepository: postRepository,
      dhikrUseCase: DhikrUseCase(
        dhikrRepository: dhikrRepository,
        connectivityUseCase: connectivityUseCase,
        authRepository: authRepository,
        notificationRepository: notificationRepository,
      ),
      prayerTimeUseCase: PrayerTimeUseCase(
        prayerRepository: prayerRepository,
        connectivityUseCase: connectivityUseCase,
      ),
      syncPermissionUseCase: SyncPermissionUseCase(
        getPermissionStatesUseCase: GetPermissionStatesUseCase.custom(({
          required int? androidVersionSdkNumber,
        }) async => permissionStates),
        requestPermissionUseCase: RequestPermissionUseCase.custom(
          ({
            required Permission permission,
            required int? androidVersionSdkNumber,
          }) async => PermissionState.granted,
        ),
        appRepository: appRepository,
        notificationService: notificationService,
      ),
      wipeDataUseCase: WipeDataUseCase(
        dhikrRepository: dhikrRepository,
        prayerRepository: prayerRepository,
        userRepository: userRepository,
        notificationRepository: notificationRepository,
      ),
      schedulePrayerNotificationsUseCase: SchedulePrayerNotificationsUseCase(
        prayerRepository: prayerRepository,
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
      syncRevenueCatStatusUseCase: SyncRevenueCatStatusUseCase(
        purchaseRepository: purchaseRepository,
      ),
      admobService: adMobService,
      scheduleDhikrCreateReminderUseCase: ScheduleDhikrCreateReminderUseCase(
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
    );
  }

  /// Flips the auth state to signed-in and lets the resulting `initApp`
  /// command run to completion.
  Future<void> signIn() async {
    authRepository.isSignedInNotifier.value = true;
    await pumpEventQueue();
  }

  setUp(() {
    appRepository = FakeAppRepository(
      // lastLimitResetDate (2026-03-15) is in the past relative to today.
      preferences: Fixtures.appPreferences(isNotificationsEnabled: false),
    );
    authRepository = FakeAuthRepository(auth: Fixtures.auth(), isSignedIn: false);
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    hiveRepository = FakeHiveRepository();
    postRepository = FakePostRepository();
    dhikrRepository = FakeDhikrRepository();
    prayerRepository = FakePrayerRepository()
      ..getPrayerTimesLocallyResult = Ok(Fixtures.prayer(days: 7));
    notificationRepository = FakeNotificationRepository();
    purchaseRepository = FakePurchaseRepository();
    connectivityUseCase = FakeConnectivityUseCase();
    adMobService = RecordingAdMobService();
    notificationService = StubNotificationService();
    permissionStates = PermissionStates(notification: PermissionState.granted);
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('listenables mirror the repositories', () {
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
    expect(viewModel.auth, same(authRepository.authNotifier));
    expect(viewModel.isSignedIn, same(authRepository.isSignedInNotifier));
    expect(viewModel.appPreferences, same(appRepository.appPreferencesNotifier));
  });

  group('signing in runs initApp', () {
    test(
      'loads preferences, resets the stale daily limit, initialises Hive, '
      'syncs dhikrs, inits the user, syncs RevenueCat, initialises AdMob and '
      'fetches saved post ids',
      () async {
        await signIn();

        expect(viewModel.initApp.completed.value, isTrue);
        expect(appRepository.calls, ['getPreferences()', 'resetAssistantDailyLimit()']);
        expect(hiveRepository.calls, ['initializeHive()']);
        expect(dhikrRepository.calls, contains('getUnsyncedDhikrs()'));
        expect(userRepository.calls, ['initUser(uid=uid-1)']);
        expect(purchaseRepository.calls, ['syncPremiumStatusWithBackend()']);
        expect(adMobService.initializeCalls, 1);
        expect(postRepository.calls, ['fetchSavedPostIds(userId=uid-1)']);
        // Notifications are disabled, so no scheduling happens.
        expect(notificationRepository.calls, isEmpty);
        expect(prayerRepository.calls, isEmpty);
      },
    );

    test('does not reset the daily limit when it was already reset today', () async {
      viewModel.dispose();
      appRepository.appPreferencesNotifier.value = AppPreferences.empty();
      viewModel = build();

      await signIn();

      expect(appRepository.calls, ['getPreferences()']);
    });

    test('skips AdMob initialisation for a premium user', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.yearly,
      );

      await signIn();

      expect(adMobService.initializeCalls, 0);
      expect(purchaseRepository.calls, ['syncPremiumStatusWithBackend()']);
      expect(postRepository.calls, ['fetchSavedPostIds(userId=uid-1)']);
    });

    test(
      'with notifications enabled and a full location: schedules the dhikr '
      'creation reminder, loads prayer times and schedules the week',
      () async {
        appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        );

        await signIn();

        expect(viewModel.initApp.completed.value, isTrue);
        expect(notificationRepository.calls.first, 'cancelDhikrCreationReminderNotifications()');
        expect(notificationRepository.scheduledDhikrCreationReminders, hasLength(3));
        expect(
          notificationRepository.scheduledDhikrCreationReminders.map((r) => r.userName).toSet(),
          {'Ahmet'},
        );
        expect(
          prayerRepository.calls.first,
          'getPrayerTimesLocally(districtId=9541, city=İstanbul, country=Türkiye)',
        );
        expect(notificationRepository.calls, contains('cancelAllPrayerNotifications()'));
        expect(notificationRepository.scheduledPrayerNotifications, isNotEmpty);
      },
      skip: skipOnIos,
    );

    test(
      'with notifications enabled but an empty location: schedules the '
      'creation reminder and skips prayer times',
      () async {
        appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        );
        userRepository.currentUserNotifier.value = Fixtures.user(
          country: '',
          city: '',
          districtId: '',
        );

        await signIn();

        expect(viewModel.initApp.completed.value, isTrue);
        expect(notificationRepository.scheduledDhikrCreationReminders, hasLength(3));
        expect(prayerRepository.calls, isEmpty);
        expect(notificationRepository.scheduledPrayerNotifications, isEmpty);
      },
      skip: skipOnIos,
    );

    // `_initApp` dereferences `districtId!` / `city!` / `country!`; a user
    // document without those fields makes the whole init fail with the
    // generic Turkish message instead of merely skipping prayer times.
    test(
      "with notifications enabled and a null location: fails with "
      "'Uygulama başlatılamadı'",
      () async {
        appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        );
        userRepository.currentUserNotifier.value = Fixtures.user(
          country: null,
          city: null,
          districtId: null,
        );

        await signIn();

        expect(viewModel.initApp.error.value, isTrue);
        expect(
          viewModel.initApp.result.value!.asError.error.toString(),
          contains('Uygulama başlatılamadı'),
        );
        expect(prayerRepository.calls, isEmpty);
      },
      skip: skipOnIos,
    );

    test(
      'a revoked notification permission disables the preference before any '
      'scheduling (real SyncPermissionUseCase)',
      () async {
        appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        );
        permissionStates = PermissionStates(notification: PermissionState.permanentlyDenied);

        await signIn();

        expect(viewModel.initApp.completed.value, isTrue);
        expect(appRepository.calls, contains('updateIsNotificationsEnabled(false)'));
        expect(appRepository.appPreferencesNotifier.value.isNotificationsEnabled, isFalse);
        expect(notificationRepository.calls, isEmpty);
        expect(prayerRepository.calls, isEmpty);
      },
      skip: skipOnIos,
    );

    test('a getPreferences error aborts initApp before any other work', () async {
      final exception = Exception('prefs');
      appRepository.getPreferencesResult = Error<AppPreferences>(exception);

      await signIn();

      expect(viewModel.initApp.error.value, isTrue);
      expect(viewModel.initApp.result.value!.asError.error, same(exception));
      expect(appRepository.calls, ['getPreferences()']);
      expect(hiveRepository.calls, isEmpty);
      expect(dhikrRepository.calls, isEmpty);
      expect(userRepository.calls, isEmpty);
      expect(purchaseRepository.calls, isEmpty);
      expect(adMobService.initializeCalls, 0);
      expect(postRepository.calls, isEmpty);
    });

    test('an unregistered user skips RevenueCat, AdMob and saved posts', () async {
      userRepository.initUserResult = const Ok(false);

      await signIn();

      expect(viewModel.initApp.completed.value, isTrue);
      expect(userRepository.calls, ['initUser(uid=uid-1)']);
      expect(purchaseRepository.calls, isEmpty);
      expect(adMobService.initializeCalls, 0);
      expect(postRepository.calls, isEmpty);
    });

    test('an initUser failure is logged and the app still initialises', () async {
      userRepository.initUserResult = Error<bool>(Exception('firestore'));

      await signIn();

      expect(viewModel.initApp.completed.value, isTrue);
      expect(purchaseRepository.calls, isEmpty);
      expect(adMobService.initializeCalls, 0);
    });

    test('does not init the user when the auth record has no uid', () async {
      authRepository.authNotifier.value = Auth.empty();

      await signIn();

      expect(viewModel.initApp.completed.value, isTrue);
      expect(hiveRepository.calls, ['initializeHive()']);
      expect(userRepository.calls, isEmpty);
      expect(purchaseRepository.calls, isEmpty);
    });
  });

  group('signing out runs wipeData', () {
    test('clears dhikrs, prayer times, notifications and the user', () async {
      authRepository.isSignedInNotifier.value = true;
      await pumpEventQueue();
      dhikrRepository.calls.clear();

      authRepository.isSignedInNotifier.value = false;
      await pumpEventQueue();

      expect(viewModel.wipeData.completed.value, isTrue);
      expect(dhikrRepository.calls, ['clearAllDhikrsLocally()']);
      expect(prayerRepository.calls, ['clearAllPrayerTimesLocally()']);
      expect(notificationRepository.calls, ['cancelAllNotifications()']);
      expect(userRepository.calls, contains('wipeUser()'));
      expect(userRepository.currentUserNotifier.value.isEmpty(), isTrue);
    });

    test('propagates the first failing step', () async {
      final exception = Exception('hive');
      dhikrRepository.clearAllDhikrsLocallyResult = Error<void>(exception);

      await viewModel.wipeData.execute();

      expect(viewModel.wipeData.error.value, isTrue);
      expect(viewModel.wipeData.result.value!.asError.error, same(exception));
      expect(prayerRepository.calls, isEmpty);
      expect(userRepository.calls, isNot(contains('wipeUser()')));
    });
  });

  group('initUser command', () {
    test("errors with 'User not authenticated' when the auth uid is empty", () async {
      authRepository.authNotifier.value = Auth.empty();

      await viewModel.initUser.execute();

      expect(viewModel.initUser.error.value, isTrue);
      expect(
        viewModel.initUser.result.value!.asError.error.toString(),
        contains('User not authenticated'),
      );
      expect(userRepository.calls, isEmpty);
    });

    test('calls initUser with the auth uid and returns the repository value', () async {
      await viewModel.initUser.execute();

      expect(userRepository.calls, ['initUser(uid=uid-1)']);
      expect((viewModel.initUser.result.value! as Ok<bool>).value, isTrue);
    });

    test('propagates a repository error', () async {
      final exception = Exception('firestore');
      userRepository.initUserResult = Error<bool>(exception);

      await viewModel.initUser.execute();

      expect(viewModel.initUser.error.value, isTrue);
      expect(viewModel.initUser.result.value!.asError.error, same(exception));
    });
  });

  test('dispose stops reacting to auth changes', () async {
    viewModel.dispose();

    authRepository.isSignedInNotifier.value = true;
    await pumpEventQueue();

    expect(appRepository.calls, isEmpty);
    viewModel = build();
  });
}
