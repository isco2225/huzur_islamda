import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeDhikrRepository dhikrRepository;
  late FakeUserRepository userRepository;
  late FakeAuthRepository authRepository;
  late FakeNotificationRepository notificationRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late RecordingAdMobService adMobService;
  late CreateDhikrViewModel viewModel;

  /// `ScheduleDhikrReminderUseCase.scheduleForDay` skips scheduling once
  /// 22:00 has passed, so the reminder assertions depend on wall-clock time.
  final reminderStillAhead = DateTime.now().hour < 22;

  CreateDhikrViewModel build() {
    return CreateDhikrViewModel(
      dhikrRepository: dhikrRepository,
      userRepository: userRepository,
      dhikrUseCase: DhikrUseCase(
        dhikrRepository: dhikrRepository,
        connectivityUseCase: connectivityUseCase,
        authRepository: authRepository,
        notificationRepository: notificationRepository,
      ),
      showAdUseCase: ShowAdUseCase(
        admobService: adMobService,
        userRepository: userRepository,
      ),
      scheduleDhikrReminderUseCase: ScheduleDhikrReminderUseCase(
        notificationRepository: notificationRepository,
        userRepository: userRepository,
      ),
    );
  }

  setUp(() {
    dhikrRepository = FakeDhikrRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    notificationRepository = FakeNotificationRepository();
    connectivityUseCase = FakeConnectivityUseCase();
    adMobService = RecordingAdMobService();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('targetCount defaults to 33 and currentUser mirrors the repository', () {
    expect(viewModel.targetCount.value, 33);
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
  });

  group('createDhikr', () {
    test('errors when the current user has no uid', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.createDhikr.execute((name: 'Subhanallah', targetCount: 33));

      expect(viewModel.createDhikr.error.value, isTrue);
      expect(
        viewModel.createDhikr.result.value!.asError.error.toString(),
        contains('Kullanıcı bilgisi bulunamadı'),
      );
      expect(dhikrRepository.calls, isEmpty);
    });

    test(
      'saves the dhikr locally with the given name/target and returns a '
      'non-empty id',
      () async {
        await viewModel.createDhikr.execute((name: 'Estağfirullah', targetCount: 100));

        expect(viewModel.createDhikr.completed.value, isTrue);
        final id = (viewModel.createDhikr.result.value! as Ok<String>).value;
        expect(id, isNotEmpty);

        final saved = dhikrRepository.savedDhikrs.single;
        expect(saved.id, id);
        expect(saved.userId, 'uid-1');
        expect(saved.name, 'Estağfirullah');
        expect(saved.targetCount, 100);
        expect(saved.currentCount, 0);
        expect(saved.isCompleted, isFalse);
        expect(saved.isSynced, isFalse);
        expect(saved.isDeleted, isFalse);
        expect(saved.groupId, isNull);
      },
    );

    test(
      'cancels the creation reminder, schedules the day reminder and syncs '
      '(real DhikrUseCase + ScheduleDhikrReminderUseCase)',
      () async {
        await viewModel.createDhikr.execute((name: 'Subhanallah', targetCount: 33));

        expect(
          notificationRepository.calls.first,
          'cancelTodayDhikrCreationReminderNotification(userId=uid-1)',
        );
        if (reminderStillAhead) {
          expect(notificationRepository.scheduledDhikrReminders, hasLength(1));
          expect(notificationRepository.scheduledDhikrReminders.single.userId, 'uid-1');
        } else {
          expect(notificationRepository.scheduledDhikrReminders, isEmpty);
        }
        // syncDhikrs went through the connectivity check and count comparison.
        expect(
          dhikrRepository.calls,
          containsAllInOrder([
            startsWith('saveDhikrLocally(id='),
            'getUnsyncedDhikrs()',
            'getFirestoreDhikrsCount(userId=uid-1)',
            'getDhikrsCountLocally()',
          ]),
        );
        expect(connectivityUseCase.calls, ['connectionType()']);
      },
    );

    test('still succeeds when the reminder and sync steps fail', () async {
      notificationRepository.cancelTodayDhikrCreationReminderNotificationResult =
          Error<void>(Exception('cancel'));
      notificationRepository.scheduleDhikrCompletionReminderNotificationResult =
          Error<void>(Exception('schedule'));
      dhikrRepository.getUnsyncedDhikrsResult = Error<List<Dhikr>?>(Exception('sync'));

      await viewModel.createDhikr.execute((name: 'Subhanallah', targetCount: 33));

      expect(viewModel.createDhikr.completed.value, isTrue);
    });

    test('propagates a saveDhikrLocally error and skips the follow-up steps', () async {
      final exception = Exception('hive');
      dhikrRepository.saveDhikrLocallyResult = Error<void>(exception);

      await viewModel.createDhikr.execute((name: 'Subhanallah', targetCount: 33));

      expect(viewModel.createDhikr.error.value, isTrue);
      expect(viewModel.createDhikr.result.value!.asError.error, same(exception));
      expect(notificationRepository.calls, isEmpty);
      expect(dhikrRepository.calls, hasLength(1));
    });
  });

  group('createDhikrsForPrayer', () {
    test('errors when the current user has no uid', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.createDhikrsForPrayer.execute();

      expect(viewModel.createDhikrsForPrayer.error.value, isTrue);
      expect(dhikrRepository.calls, isEmpty);
    });

    test(
      'creates the three prayer dhikrs with constant names, target 33, a '
      "shared 'prayer_dhikr_' group id and 'Namaz Tesbihatı' display name",
      () async {
        await viewModel.createDhikrsForPrayer.execute();

        expect(viewModel.createDhikrsForPrayer.completed.value, isTrue);
        final group = dhikrRepository.createdGroups.single;
        expect(group, hasLength(3));
        expect(
          group.map((d) => d.name).toList(),
          PrayerDhikrConstants.prayerDhikrNames,
        );
        expect(
          group.map((d) => d.targetCount).toSet(),
          {PrayerDhikrConstants.prayerDhikrTargetCount},
        );
        final groupId = group.first.groupId!;
        expect(groupId, startsWith('prayer_dhikr_'));
        expect(group.map((d) => d.groupId).toSet(), {groupId});
        expect(group.map((d) => d.groupDisplayName).toSet(), {'Namaz Tesbihatı'});
        expect(group.map((d) => d.userId).toSet(), {'uid-1'});
        expect(group.every((d) => d.currentCount == 0 && !d.isSynced), isTrue);

        final ids = (viewModel.createDhikrsForPrayer.result.value! as Ok<List<String>>).value;
        expect(ids, group.map((d) => d.id).toList());
        expect(ids, [
          '${groupId}_subhanallah',
          '${groupId}_elhamdulillah',
          '${groupId}_allahu_ekber',
        ]);
      },
    );

    test('syncs and schedules the day reminder after creating the group', () async {
      await viewModel.createDhikrsForPrayer.execute();

      expect(dhikrRepository.calls, contains('getUnsyncedDhikrs()'));
      if (reminderStillAhead) {
        expect(notificationRepository.scheduledDhikrReminders, hasLength(1));
      } else {
        expect(notificationRepository.scheduledDhikrReminders, isEmpty);
      }
    });

    test('propagates a createGroupDhikrs error', () async {
      final exception = Exception('hive');
      dhikrRepository.createGroupDhikrsResult = Error<void>(exception);

      await viewModel.createDhikrsForPrayer.execute();

      expect(viewModel.createDhikrsForPrayer.error.value, isTrue);
      expect(
        viewModel.createDhikrsForPrayer.result.value!.asError.error,
        same(exception),
      );
      expect(notificationRepository.calls, isEmpty);
    });
  });

  group('showInterstitialAd', () {
    test('delegates to the ad service for a non-premium user', () async {
      await viewModel.showInterstitialAd();

      expect(adMobService.showInterstitialCalls, 1);
    });

    test('skips the ad for a premium user', () async {
      userRepository.currentUserNotifier.value = Fixtures.user(
        supportPackage: SupportPackage.yearly,
      );

      await viewModel.showInterstitialAd();

      expect(adMobService.showInterstitialCalls, 0);
    });
  });
}
