import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';

class OnboardingViewModel {
  OnboardingViewModel({required AppRepository appRepository})
    : _appRepository = appRepository {
    // DEFINE COMMANDS
    updateIsOnboardingCompleted = Command0<void>(
      _updateIsOnboardingCompleted,
      debugLabel: 'updateIsOnboardingCompleted',
    );
  }

  // LOGGER
  final _log = Logger('OnboardingViewModel');

  // REPOSITORIES & USE CASES
  final AppRepository _appRepository;

  // DOMAIN

  // COMMANDS
  late Command0<void> updateIsOnboardingCompleted;

  // DISPOSE
  void dispose() {
    updateIsOnboardingCompleted.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _updateIsOnboardingCompleted() async {
    final result = await _appRepository.updateIsOnboardingCompleted(
      isOnboardingCompleted: true,
    );
    switch (result) {
      case Ok():
        _log.info('Onboarding completed updated successfully');
        return Result.ok(null);
      case Error():
        _log.severe(
          'Failed to update onboarding completed: ${result.asError.error}',
        );
        return Result.error(result.asError.error);
    }
  }
}
