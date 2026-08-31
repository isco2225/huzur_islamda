import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeDhikrRepository dhikrRepository;
  late FakeUserRepository userRepository;
  late FakeAuthRepository authRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late FetchDhikrsViewModel viewModel;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  /// A timestamp on [today] offset by [minutes] (keeps ordering deterministic).
  DateTime at(int minutes) => today.add(Duration(minutes: minutes));

  FetchDhikrsViewModel build() {
    return FetchDhikrsViewModel(
      dhikrRepository: dhikrRepository,
      userRepository: userRepository,
      dhikrUseCase: DhikrUseCase(
        dhikrRepository: dhikrRepository,
        connectivityUseCase: connectivityUseCase,
        authRepository: authRepository,
        notificationRepository: FakeNotificationRepository(),
      ),
    );
  }

  setUp(() {
    dhikrRepository = FakeDhikrRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = build();
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('initial state', () {
    test('selectedDate is today at midnight', () {
      expect(viewModel.selectedDate.value, today);
      expect(viewModel.canGoToNextDay, isFalse);
    });

    test('loads all local dhikrs from the constructor', () async {
      await pumpEventQueue();

      expect(dhikrRepository.calls, ['loadAllDhikrsLocally()']);
    });

    test('isInitialLoading stays true until the local list first emits', () async {
      await pumpEventQueue();
      expect(viewModel.isInitialLoading.value, isTrue);

      dhikrRepository.dhikrsLocallyNotifier.value = [];

      expect(viewModel.isInitialLoading.value, isFalse);
      expect(viewModel.dhikrs.value, isNull);
      expect(viewModel.groupDhikrs.value, isNull);
    });
  });

  group('dhikrs derived from the local list', () {
    test('contains only ungrouped dhikrs of the selected date sorted by lastUpdatedAt desc', () {
      dhikrRepository.dhikrsLocallyNotifier.value = [
        Fixtures.dhikr(id: 'old', day: today, lastUpdatedAt: at(1)),
        Fixtures.dhikr(id: 'yesterday', day: yesterday, lastUpdatedAt: at(9)),
        Fixtures.dhikr(id: 'new', day: today, lastUpdatedAt: at(5)),
        Fixtures.dhikr(id: 'grouped', day: today, groupId: 'grp', lastUpdatedAt: at(7)),
        Fixtures.dhikr(id: 'empty-group', day: today, groupId: '', lastUpdatedAt: at(3)),
      ];

      expect(viewModel.dhikrs.value?.map((d) => d.id).toList(), ['new', 'empty-group', 'old']);
    });

    test('is null when the selected date only holds grouped dhikrs', () {
      dhikrRepository.dhikrsLocallyNotifier.value = [
        Fixtures.dhikr(id: 'grouped', day: today, groupId: 'grp'),
      ];

      expect(viewModel.dhikrs.value, isNull);
      expect(viewModel.groupDhikrs.value, hasLength(1));
    });

    test('re-derives when the selected date changes', () {
      dhikrRepository.dhikrsLocallyNotifier.value = [
        Fixtures.dhikr(id: 'today', day: today),
        Fixtures.dhikr(id: 'yesterday', day: yesterday),
      ];
      expect(viewModel.dhikrs.value?.single.id, 'today');

      viewModel.goToPreviousDay();

      expect(viewModel.dhikrs.value?.single.id, 'yesterday');
    });
  });

  group('groupDhikrs derived from the local list', () {
    test(
      'groups by groupId, orders prayer names per PrayerDhikrConstants and '
      'sorts groups by earliest createdAt desc',
      () {
        dhikrRepository.dhikrsLocallyNotifier.value = [
          // Older group, inserted in scrambled order.
          Fixtures.dhikr(
            id: 'a-allahu',
            day: today,
            groupId: 'group-a',
            groupDisplayName: 'Namaz Tesbihatı',
            name: PrayerDhikrConstants.allahuEkberName,
            createdAt: at(10),
          ),
          Fixtures.dhikr(
            id: 'a-subhan',
            day: today,
            groupId: 'group-a',
            groupDisplayName: 'Namaz Tesbihatı',
            name: PrayerDhikrConstants.subhanallahName,
            createdAt: at(12),
          ),
          Fixtures.dhikr(
            id: 'a-elham',
            day: today,
            groupId: 'group-a',
            groupDisplayName: 'Namaz Tesbihatı',
            name: PrayerDhikrConstants.elhamdulillahName,
            createdAt: at(11),
          ),
          // Newer mood group with non-prayer names (keep insertion order).
          Fixtures.dhikr(
            id: 'b-1',
            day: today,
            groupId: 'group-b',
            groupDisplayName: 'Huzur',
            name: 'Estağfirullah',
            createdAt: at(30),
          ),
          Fixtures.dhikr(
            id: 'b-2',
            day: today,
            groupId: 'group-b',
            groupDisplayName: 'Huzur',
            name: 'La ilahe illallah',
            createdAt: at(31),
          ),
          // Another day: must be excluded.
          Fixtures.dhikr(id: 'c', day: yesterday, groupId: 'group-c', createdAt: at(99)),
        ];

        final groups = viewModel.groupDhikrs.value!;
        expect(groups.map((g) => g.groupId).toList(), ['group-b', 'group-a']);

        final groupA = groups.last;
        expect(groupA.groupName, 'Namaz Tesbihatı');
        expect(groupA.dhikrs.map((d) => d.name).toList(), PrayerDhikrConstants.prayerDhikrNames);

        final groupB = groups.first;
        expect(groupB.groupName, 'Huzur');
        expect(groupB.dhikrs.map((d) => d.id).toList(), ['b-1', 'b-2']);
        expect(viewModel.dhikrs.value, isNull);
      },
    );

    test("falls back to 'Namaz Tesbihatı' when the group has no display name", () {
      dhikrRepository.dhikrsLocallyNotifier.value = [
        Fixtures.dhikr(id: 'x', day: today, groupId: 'grp'),
      ];

      expect(viewModel.groupDhikrs.value!.single.groupName, 'Namaz Tesbihatı');
    });

    test('is null when no grouped dhikr exists for the date', () {
      dhikrRepository.dhikrsLocallyNotifier.value = [
        Fixtures.dhikr(id: 'plain', day: today),
      ];

      expect(viewModel.groupDhikrs.value, isNull);
      expect(viewModel.dhikrs.value, hasLength(1));
    });
  });

  group('date navigation', () {
    test('goToPreviousDay moves one day back and enables goToNextDay', () {
      viewModel.goToPreviousDay();

      expect(viewModel.selectedDate.value, yesterday);
      expect(viewModel.canGoToNextDay, isTrue);
    });

    test('goToNextDay returns to today but never goes into the future', () {
      viewModel.goToPreviousDay();
      viewModel.goToNextDay();
      expect(viewModel.selectedDate.value, today);
      expect(viewModel.canGoToNextDay, isFalse);

      viewModel.goToNextDay();

      expect(viewModel.selectedDate.value, today);
    });

    test('goToToday jumps back from several days ago', () {
      viewModel.goToPreviousDay();
      viewModel.goToPreviousDay();
      viewModel.goToPreviousDay();
      expect(viewModel.selectedDate.value, today.subtract(const Duration(days: 3)));

      viewModel.goToToday();

      expect(viewModel.selectedDate.value, today);
    });

    test('changing the date flips isInitialLoading to false', () {
      expect(viewModel.isInitialLoading.value, isTrue);

      viewModel.goToPreviousDay();

      expect(viewModel.isInitialLoading.value, isFalse);
    });
  });

  group('fetchDhikrs', () {
    test('errors when there is no authenticated user', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.fetchDhikrs.execute(today);

      expect(viewModel.fetchDhikrs.error.value, isTrue);
      expect(
        viewModel.fetchDhikrs.result.value!.asError.error,
        isA<DhikrUserIdEmpty>(),
      );
      expect(dhikrRepository.calls, isNot(contains(startsWith('getAllDhikrsByDateLocally'))));
    });

    test('queries the repository for the date and exposes ungrouped dhikrs sorted desc', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = Ok([
        Fixtures.dhikr(id: 'old', lastUpdatedAt: at(1)),
        Fixtures.dhikr(id: 'grouped', groupId: 'grp', lastUpdatedAt: at(9)),
        Fixtures.dhikr(id: 'new', lastUpdatedAt: at(5)),
      ]);

      await viewModel.fetchDhikrs.execute(today);

      expect(
        dhikrRepository.calls,
        contains('getAllDhikrsByDateLocally(date=${today.toIso8601String().substring(0, 10)})'),
      );
      expect(viewModel.dhikrs.value?.map((d) => d.id).toList(), ['new', 'old']);
      expect(viewModel.fetchDhikrs.completed.value, isTrue);
    });

    test('sets dhikrs to null when the repository returns null', () async {
      dhikrRepository.getAllDhikrsByDateLocallyResult = const Ok(null);

      await viewModel.fetchDhikrs.execute(today);

      expect(viewModel.dhikrs.value, isNull);
      expect(viewModel.fetchDhikrs.completed.value, isTrue);
    });

    test('propagates a repository error and nulls dhikrs', () async {
      final exception = Exception('hive');
      dhikrRepository.getAllDhikrsByDateLocallyResult = Error<List<Dhikr>?>(exception);

      await viewModel.fetchDhikrs.execute(today);

      expect(viewModel.fetchDhikrs.error.value, isTrue);
      expect(viewModel.fetchDhikrs.result.value!.asError.error, same(exception));
      expect(viewModel.dhikrs.value, isNull);
    });
  });

  group('deleteGroup (real DhikrUseCase.deleteGroup)', () {
    test('deletes every member remotely and locally in order', () async {
      await viewModel.deleteGroup.execute(['g-1', 'g-2']);

      expect(
        dhikrRepository.calls,
        containsAllInOrder([
          'deleteDhikrFromFirestore(dhikrId=g-1, userId=uid-1)',
          'deleteDhikrLocally(dhikrId=g-1)',
          'deleteDhikrFromFirestore(dhikrId=g-2, userId=uid-1)',
          'deleteDhikrLocally(dhikrId=g-2)',
        ]),
      );
      expect(viewModel.deleteGroup.completed.value, isTrue);
    });

    test('errors on an empty id list without touching the repository', () async {
      await pumpEventQueue();
      dhikrRepository.calls.clear();

      await viewModel.deleteGroup.execute([]);

      expect(viewModel.deleteGroup.error.value, isTrue);
      expect(dhikrRepository.calls, isEmpty);
    });

    test('stops at the first failing member and propagates the error', () async {
      final exception = Exception('firestore');
      dhikrRepository.onDeleteDhikrFromFirestore = (id) async =>
          id == 'g-2' ? Error<void>(exception) : const Ok(null);

      await viewModel.deleteGroup.execute(['g-1', 'g-2', 'g-3']);

      expect(viewModel.deleteGroup.error.value, isTrue);
      expect(viewModel.deleteGroup.result.value!.asError.error, same(exception));
      expect(dhikrRepository.calls, isNot(contains('deleteDhikrFromFirestore(dhikrId=g-3, userId=uid-1)')));
      expect(dhikrRepository.calls, isNot(contains('deleteDhikrLocally(dhikrId=g-2)')));
    });

    test('fails with ConnectivityNoConnection when offline', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.deleteGroup.execute(['g-1']);

      expect(viewModel.deleteGroup.error.value, isTrue);
      expect(viewModel.deleteGroup.result.value!.asError.error, isA<ConnectivityNoConnection>());
    });
  });
}
