import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';

class AuthViewModel {
  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // DEFINE COMMANDS

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('AuthViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;

  // DOMAIN
  ValueListenable<Auth> get auth => _authRepository.auth;

  // COMMANDS

  // DISPOSE
  void dispose() {}

  // FUNCTIONS
}
