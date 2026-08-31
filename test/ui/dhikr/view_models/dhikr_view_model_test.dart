import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late FakeDhikrRepository dhikrRepository;
  late FakeAuthRepository authRepository;
  late FakeConnectivityUseCase connectivityUseCase;
  late DhikrViewModel viewModel;

  setUp(() {
    dhikrRepository = FakeDhikrRepository();
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    connectivityUseCase = FakeConnectivityUseCase();
    viewModel = DhikrViewModel(
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

  group('syncDhikrs (real DhikrUseCase)', () {
    test('skips the sync and completes Ok when offline', () async {
      connectivityUseCase.type = ConnectivityEnum.none;

      await viewModel.syncDhikrs.execute();

      expect(viewModel.syncDhikrs.completed.value, isTrue);
      expect(dhikrRepository.calls, isEmpty);
    });

    test('pushes unsynced dhikrs to Firestore', () async {
      dhikrRepository.getUnsyncedDhikrsResult = Ok([
        Fixtures.dhikr(id: 'd-1', isSynced: false),
      ]);

      await viewModel.syncDhikrs.execute();

      // Marking as synced is the repository's job (see DhikrRepositoryRemote).
      expect(dhikrRepository.calls, [
        'getUnsyncedDhikrs()',
        'syncDhikrsToFirestore(userId=uid-1)',
      ]);
      expect(viewModel.syncDhikrs.completed.value, isTrue);
    });

    test('pulls from Firestore when the remote count is larger', () async {
      dhikrRepository.getFirestoreDhikrsCountResult = const Ok(3);
      dhikrRepository.getDhikrsCountLocallyResult = const Ok(1);

      await viewModel.syncDhikrs.execute();

      expect(dhikrRepository.calls, contains('syncDhikrsToLocally(userId=uid-1)'));
      expect(viewModel.syncDhikrs.completed.value, isTrue);
    });

    test('errors when the user is not signed in', () async {
      authRepository.authNotifier.value = Auth.empty();

      await viewModel.syncDhikrs.execute();

      expect(viewModel.syncDhikrs.error.value, isTrue);
      expect(dhikrRepository.calls, isEmpty);
    });

    test('propagates a repository error', () async {
      final exception = Exception('firestore');
      dhikrRepository.getUnsyncedDhikrsResult = Error<List<Dhikr>?>(exception);

      await viewModel.syncDhikrs.execute();

      expect(viewModel.syncDhikrs.error.value, isTrue);
      expect(viewModel.syncDhikrs.result.value!.asError.error, same(exception));
    });
  });
}
