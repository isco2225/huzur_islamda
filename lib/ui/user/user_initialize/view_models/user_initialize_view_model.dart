import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class UserInitializeViewModel {
  UserInitializeViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    // DEFINE COMMANDS
    initUser = Command0(
      _initUser,
      debugLabel: 'UserInitializeViewModel.initUser',
    )..execute();
    // DEFINE LISTENERS
  }
  // LOGGER
  final _log = Logger('UserInitializeViewModel');
  // REPOSITORIES & USE CASES
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  // DOMAIN

  // COMMANDS
  late Command0<bool> initUser;

  // DISPOSE
  void dispose() {
    initUser.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result<bool>> _initUser() async {
    if (_authRepository.auth.value.uid.isEmpty) {
      return Result.error(Exception('User not authenticated'));
    }
    final result = await _userRepository.initUser(
      uid: _authRepository.auth.value.uid,
    );
    switch (result) {
      case Ok():
        _log.info('User initialized successfully');
        return result;
      case Error():
        _log.warning('Failed to init user', result.error);
        return result;
    }
  }
}
