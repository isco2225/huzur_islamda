import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class LogOutViewModel {
  LogOutViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // DEFINE COMMANDS
    logOut = Command0<void>(_logOut, debugLabel: 'logOut');
  }

  // LOGGER
  final _log = Logger('LogOutViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;

  // DOMAIN

  // COMMANDS
  late Command0<void> logOut;

  // DISPOSE
  void dispose() {
    logOut.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _logOut() async {
    final result = await _authRepository.signOut();
    _log.info('Log out result: $result');
    if (result is Error<void>) {
      _log.warning('Failed to log out: ${result.asError.error}');
    }
    return result;
  }
}
