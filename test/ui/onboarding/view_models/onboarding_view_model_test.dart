import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late FakeAppRepository appRepository;
  late OnboardingViewModel viewModel;

  setUp(() {
    appRepository = FakeAppRepository(
      preferences: Fixtures.appPreferences(isOnboardingCompleted: false),
    );
    viewModel = OnboardingViewModel(appRepository: appRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('updateIsOnboardingCompleted', () {
    test('marks onboarding as completed in the repository', () async {
      await viewModel.updateIsOnboardingCompleted.execute();

      expect(appRepository.calls, ['updateIsOnboardingCompleted(true)']);
      expect(appRepository.appPreferencesNotifier.value.isOnboardingCompleted, isTrue);
      expect(viewModel.updateIsOnboardingCompleted.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      final exception = Exception('prefs');
      appRepository.updateIsOnboardingCompletedResult = Error<void>(exception);

      await viewModel.updateIsOnboardingCompleted.execute();

      expect(viewModel.updateIsOnboardingCompleted.error.value, isTrue);
      expect(
        viewModel.updateIsOnboardingCompleted.result.value!.asError.error,
        same(exception),
      );
      expect(appRepository.appPreferencesNotifier.value.isOnboardingCompleted, isFalse);
    });
  });
}
