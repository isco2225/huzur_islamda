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
  late PrayerViewModel viewModel;

  PrayerViewModel build() {
    return PrayerViewModel(
      appRepository: appRepository,
      schedulePrayerNotificationsUseCase: SchedulePrayerNotificationsUseCase(
        prayerRepository: prayerRepository,
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
    );
  }

  setUp(() {
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(isNotificationsEnabled: false),
    );
    prayerRepository = FakePrayerRepository()
      ..getPrayerTimesLocallyResult = Ok(Fixtures.prayer(days: 7));
    notificationRepository = FakeNotificationRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('isNotificationsEnabled', () {
    test('is seeded from the app preferences', () {
      expect(viewModel.isNotificationsEnabled.value, isFalse);

      viewModel.dispose();
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: true,
      );
      viewModel = build();

      expect(viewModel.isNotificationsEnabled.value, isTrue);
    });

    test('mirrors later preference changes', () {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: true,
      );
      expect(viewModel.isNotificationsEnabled.value, isTrue);

      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: false,
      );
      expect(viewModel.isNotificationsEnabled.value, isFalse);
    });

    test('stops mirroring after dispose', () {
      viewModel.dispose();

      expect(
        () => appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        ),
        returnsNormally,
      );
      viewModel = build();
    });
  });

  group('schedulePrayerNotifications', () {
    test('short-circuits Ok without calling the use case when disabled', () async {
      await viewModel.schedulePrayerNotifications.execute();

      expect(viewModel.schedulePrayerNotifications.completed.value, isTrue);
      expect(notificationRepository.calls, isEmpty);
      expect(prayerRepository.calls, isEmpty);
    });

    test(
      'schedules the week through the real use case when enabled',
      () async {
        appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
          isNotificationsEnabled: true,
        );

        await viewModel.schedulePrayerNotifications.execute();

        expect(viewModel.schedulePrayerNotifications.completed.value, isTrue);
        expect(notificationRepository.calls.first, 'cancelAllPrayerNotifications()');
        expect(prayerRepository.calls, [
          'getPrayerTimesLocally(districtId=9541, city=İstanbul, country=Türkiye)',
        ]);
        // Every prayer still ahead of now over the next 7 days is scheduled;
        // at least the six later days contribute five each.
        expect(
          notificationRepository.scheduledPrayerNotifications.length,
          greaterThanOrEqualTo(30),
        );
      },
    );

    test('propagates the use case error when enabled and nothing is cached', () async {
      appRepository.appPreferencesNotifier.value = Fixtures.appPreferences(
        isNotificationsEnabled: true,
      );
      prayerRepository.getPrayerTimesLocallyResult = const Ok(null);

      await viewModel.schedulePrayerNotifications.execute();

      expect(viewModel.schedulePrayerNotifications.error.value, isTrue);
      expect(
        viewModel.schedulePrayerNotifications.result.value!.asError.error.toString(),
        contains('Namaz vakitleri bulunamadı'),
      );
    });
  });
}
