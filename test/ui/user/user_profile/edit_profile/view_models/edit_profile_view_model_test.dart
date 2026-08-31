import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  late FakeUserRepository userRepository;
  late FakeAuthRepository authRepository;
  late FakeAppRepository appRepository;
  late FakePrayerRepository prayerRepository;
  late FakeNotificationRepository notificationRepository;
  late EditProfileViewModel viewModel;

  EditProfileViewModel build() {
    return EditProfileViewModel(
      userRepository: userRepository,
      authRepository: authRepository,
      appRepository: appRepository,
      schedulePrayerNotificationsUseCase: SchedulePrayerNotificationsUseCase(
        prayerRepository: prayerRepository,
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
    );
  }

  setUp(() {
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(isNotificationsEnabled: false),
    );
    prayerRepository = FakePrayerRepository()
      ..getPrayerTimesLocallyResult = Ok(Fixtures.prayer(days: 7));
    notificationRepository = FakeNotificationRepository();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('updateProfile', () {
    test('returns Ok without a repository call when nothing changed', () async {
      final user = userRepository.currentUserNotifier.value;

      await viewModel.updateProfile.execute((
        name: user.name,
        surname: user.surname,
        dateOfBirth: user.dateOfBirth,
        gender: user.gender,
      ));

      expect(userRepository.calls, isEmpty);
      expect(viewModel.updateProfile.completed.value, isTrue);
      expect(viewModel.updateProfile.result.value, isA<Ok<void>>());
    });

    test('calls updateUser with the current uid when a field changed', () async {
      final user = userRepository.currentUserNotifier.value;

      await viewModel.updateProfile.execute((
        name: 'Mehmet',
        surname: user.surname,
        dateOfBirth: user.dateOfBirth,
        gender: user.gender,
      ));

      expect(userRepository.calls, ['updateUser(uid=uid-1)']);
      expect(viewModel.updateProfile.completed.value, isTrue);
    });

    test('propagates an updateUser error', () async {
      final exception = Exception('offline');
      userRepository.updateUserResult = Error<void>(exception);

      await viewModel.updateProfile.execute((
        name: 'Mehmet',
        surname: null,
        dateOfBirth: null,
        gender: null,
      ));

      expect(viewModel.updateProfile.error.value, isTrue);
      expect(
        viewModel.updateProfile.result.value!.asError.error,
        same(exception),
      );
    });
  });

  group('updateUserLocation', () {
    test('forwards uid and location fields to the repository', () async {
      await viewModel.updateUserLocation.execute((
        districtId: '9552',
        city: 'Ankara',
        country: 'Türkiye',
      ));

      expect(userRepository.calls, [
        'updateUserLocation(uid=uid-1, country=Türkiye, city=Ankara, '
            'districtId=9552)',
      ]);
      expect(viewModel.updateUserLocation.completed.value, isTrue);
    });

    test(
      'schedules the weekly prayer notifications when notifications are '
      'enabled (real SchedulePrayerNotificationsUseCase)',
      () async {
        appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        );

        await viewModel.updateUserLocation.execute((
          districtId: '9552',
          city: 'Ankara',
          country: 'Türkiye',
        ));

        expect(
          notificationRepository.calls,
          contains('cancelAllPrayerNotifications()'),
        );
        expect(prayerRepository.calls, [
          'getPrayerTimesLocally(districtId=9541, city=İstanbul, '
              'country=Türkiye)',
        ]);
        expect(viewModel.updateUserLocation.completed.value, isTrue);
      },
    );

    test('does not schedule notifications when they are disabled', () async {
      await viewModel.updateUserLocation.execute((
        districtId: '9552',
        city: 'Ankara',
        country: 'Türkiye',
      ));

      expect(notificationRepository.calls, isEmpty);
      expect(prayerRepository.calls, isEmpty);
    });

    test('a scheduling failure does not turn the Ok result into an error', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: true,
      );
      prayerRepository.getPrayerTimesLocallyResult = Error<Prayer?>(
        Exception('hive'),
      );

      await viewModel.updateUserLocation.execute((
        districtId: '9552',
        city: 'Ankara',
        country: 'Türkiye',
      ));

      expect(viewModel.updateUserLocation.completed.value, isTrue);
    });

    test('propagates an updateUserLocation error', () async {
      final exception = Exception('offline');
      userRepository.updateUserLocationResult = Error<void>(exception);

      await viewModel.updateUserLocation.execute((
        districtId: '9552',
        city: 'Ankara',
        country: 'Türkiye',
      ));

      expect(viewModel.updateUserLocation.error.value, isTrue);
      expect(
        viewModel.updateUserLocation.result.value!.asError.error,
        same(exception),
      );
      expect(notificationRepository.calls, isEmpty);
    });
  });

  group('currentUser getters', () {
    test('currentUser mirrors the repository listenable', () {
      expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
    });

    test('currentUserName etc. expose the current values', () {
      expect(viewModel.currentUserName.value, 'Ahmet');
      expect(viewModel.currentUserSurname.value, 'Yılmaz');
      expect(viewModel.currentUserDateOfBirth.value, '01/01/1990');
      expect(viewModel.currentUserGender.value, 'male');
    });

    test(
      'a listenable obtained from currentUserName follows later user updates',
      () {
        final nameListenable = viewModel.currentUserName;
        var notifications = 0;
        nameListenable.addListener(() => notifications++);

        userRepository.currentUserNotifier.value = Fixtures.user(
          name: 'Mehmet',
        );

        expect(nameListenable.value, 'Mehmet');
        expect(notifications, 1);
        expect(viewModel.currentUserSurname.value, 'Yılmaz');
      },
    );

    test('stops following the user after dispose', () {
      final nameListenable = viewModel.currentUserName;
      viewModel.dispose();

      // The listener is removed on dispose, so updating the user afterwards
      // neither throws (disposed notifier) nor changes the old value.
      userRepository.currentUserNotifier.value = Fixtures.user(name: 'Ayşe');

      expect(nameListenable.value, 'Ahmet');

      // Re-create so tearDown disposes a live instance.
      viewModel = build();
    });
  });
}
