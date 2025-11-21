import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class FetchUserViewModel {
  FetchUserViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    // DEFINE COMMANDS
    fetchCurrentUser = Command0(
      _fetchCurrentUser,
      debugLabel: 'FetchUserViewModel.fetchCurrentUser',
    );
  }
  // LOGGER
  final _log = Logger('FetchUserViewModel');
  // REPOSITORIES & USE CASES
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;
  ValueListenable<Auth> get auth => _authRepository.auth;
  // COMMANDS
  late Command0<void> fetchCurrentUser;

  // DISPOSE
  void dispose() {
    fetchCurrentUser.dispose();
    _log.fine('Disposed');
  }

  // FUNCTIONS
  Future<Result> _fetchCurrentUser() async {
    final result = await _userRepository.fetchAuthenticatedUser(
      uid: auth.value.uid,
    );
    if (result is Error<User>) {
      _log.warning('Failed to load current user', result.asError.error);
    }
    return result;
  }
}
