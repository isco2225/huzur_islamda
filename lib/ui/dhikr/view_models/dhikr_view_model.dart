import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class DhikrViewModel {
  DhikrViewModel({required DhikrUseCase dhikrUseCase})
    : _dhikrUseCase = dhikrUseCase {
    // DEFINE COMMANDS
    syncDhikrs = Command0<void>(_syncDhikrs, debugLabel: 'syncDhikrs');

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('DhikrViewModel');

  // REPOSITORIES & USE CASES
  final DhikrUseCase _dhikrUseCase;

  // DOMAIN

  // COMMANDS
  late final Command0<void> syncDhikrs;

  // DISPOSE
  void dispose() {
    syncDhikrs.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _syncDhikrs() async {
    final result = await _dhikrUseCase.syncDhikrs();
    switch (result) {
      case Ok():
        _log.info('Dhikrs synced successfully');
      case Error():
        _log.warning('Failed to sync dhikrs: ${result.error}');
    }
    return result;
  }
}
