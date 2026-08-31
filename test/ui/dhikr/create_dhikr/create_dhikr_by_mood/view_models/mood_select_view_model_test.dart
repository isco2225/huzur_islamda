import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../../helpers/helpers.dart';

const _calmMood = Mood(
  id: 'calm',
  title: 'Huzur',
  colorHex: '#00FF00',
  suggestions: [
    MoodSuggestion(
      id: 'sub',
      arabic: 'سبحان الله',
      pronunciation: 'Subhanallah',
      meaning: 'Allah eksikliklerden münezzehtir',
      benefit: 'Huzur verir',
      defaultTarget: 33,
    ),
    MoodSuggestion(
      id: 'ham',
      arabic: 'الحمد لله',
      pronunciation: 'Elhamdulillah',
      meaning: 'Hamd Allah\'a mahsustur',
      benefit: 'Şükür',
      defaultTarget: 100,
    ),
  ],
);

void main() {
  late StubDhikrMoodService moodService;
  late FakeDhikrRepository dhikrRepository;
  late FakeUserRepository userRepository;
  late FakeAuthRepository authRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late MoodSelectViewModel viewModel;

  setUp(() {
    moodService = StubDhikrMoodService()..moodsResult = const Ok([_calmMood]);
    dhikrRepository = FakeDhikrRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = MoodSelectViewModel(
      moodService: moodService,
      dhikrRepository: dhikrRepository,
      userRepository: userRepository,
      dhikrUseCase: DhikrUseCase(
        dhikrRepository: dhikrRepository,
        connectivityUseCase: connectivityUseCase,
        authRepository: authRepository,
        notificationRepository: FakeNotificationRepository(),
      ),
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('loadMoods', () {
    test('starts in the loading state with no moods and no error', () {
      expect(viewModel.isLoadingMoods.value, isTrue);
      expect(viewModel.moods.value, isNull);
      expect(viewModel.loadMoodsError.value, isNull);
    });

    test('populates moods and clears loading on Ok', () async {
      await viewModel.loadMoods();

      expect(moodService.getDhikrMoodsCalls, 1);
      expect(viewModel.isLoadingMoods.value, isFalse);
      expect(viewModel.moods.value, [_calmMood]);
      expect(viewModel.loadMoodsError.value, isNull);
    });

    test('exposes the error, nulls moods and clears loading on Error', () async {
      final exception = Exception('asset missing');
      moodService.moodsResult = Error<List<Mood>>(exception);

      await viewModel.loadMoods();

      expect(viewModel.isLoadingMoods.value, isFalse);
      expect(viewModel.moods.value, isNull);
      expect(viewModel.loadMoodsError.value, same(exception));
    });

    test('a successful reload after a failure clears the error', () async {
      moodService.moodsResult = Error<List<Mood>>(Exception('first'));
      await viewModel.loadMoods();
      moodService.moodsResult = const Ok([_calmMood]);

      await viewModel.loadMoods();

      expect(viewModel.loadMoodsError.value, isNull);
      expect(viewModel.moods.value, [_calmMood]);
    });
  });

  group('createDhikrsForMood', () {
    test('errors when the current user has no uid', () async {
      userRepository.currentUserNotifier.value = User.empty();

      await viewModel.createDhikrsForMood.execute(_calmMood);

      expect(viewModel.createDhikrsForMood.error.value, isTrue);
      expect(
        viewModel.createDhikrsForMood.result.value!.asError.error.toString(),
        contains('Kullanıcı bilgisi bulunamadı'),
      );
      expect(dhikrRepository.calls, isEmpty);
    });

    test(
      'maps every suggestion to a dhikr: id <groupId>_<suggestionId>, '
      'name = pronunciation, target = defaultTarget, group name = mood title',
      () async {
        await viewModel.createDhikrsForMood.execute(_calmMood);

        expect(viewModel.createDhikrsForMood.completed.value, isTrue);
        final group = dhikrRepository.createdGroups.single;
        expect(group, hasLength(2));

        final groupId = group.first.groupId!;
        expect(groupId, startsWith('mood_dhikr_'));
        expect(group.map((d) => d.id).toList(), ['${groupId}_sub', '${groupId}_ham']);
        expect(group.map((d) => d.name).toList(), ['Subhanallah', 'Elhamdulillah']);
        expect(group.map((d) => d.targetCount).toList(), [33, 100]);
        expect(group.map((d) => d.groupDisplayName).toSet(), {'Huzur'});
        expect(group.map((d) => d.userId).toSet(), {'uid-1'});
        expect(group.first.arabic, 'سبحان الله');
        expect(group.first.meaning, 'Allah eksikliklerden münezzehtir');
        expect(group.first.benefit, 'Huzur verir');
        expect(group.every((d) => d.currentCount == 0 && !d.isSynced), isTrue);

        final ids = (viewModel.createDhikrsForMood.result.value! as Ok<List<String>>).value;
        expect(ids, group.map((d) => d.id).toList());
      },
    );

    test('syncs through the real DhikrUseCase after saving the group', () async {
      await viewModel.createDhikrsForMood.execute(_calmMood);

      expect(
        dhikrRepository.calls,
        containsAllInOrder(['createGroupDhikrs(count=2)', 'getUnsyncedDhikrs()']),
      );
      expect(connectivityUseCase.calls, ['connectionType()']);
    });

    test('propagates a createGroupDhikrs error and does not sync', () async {
      final exception = Exception('hive');
      dhikrRepository.createGroupDhikrsResult = Error<void>(exception);

      await viewModel.createDhikrsForMood.execute(_calmMood);

      expect(viewModel.createDhikrsForMood.error.value, isTrue);
      expect(viewModel.createDhikrsForMood.result.value!.asError.error, same(exception));
      expect(dhikrRepository.calls, ['createGroupDhikrs(count=2)']);
    });
  });
}
