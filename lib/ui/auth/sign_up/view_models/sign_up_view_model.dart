import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class SignUpViewModel {
  SignUpViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // DEFINE COMMANDS
    requestSignUp = Command1<void, ({String email, String password})>(
      _requestSignUp,
      debugLabel: 'requestSignUp',
    );

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('SignUpViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;

  // DOMAIN
  ValueListenable<Auth> get auth => _authRepository.auth;

  // COMMANDS
  late final Command1<void, ({String email, String password})> requestSignUp;

  // DISPOSE
  void dispose() {
    requestSignUp.dispose();
  }

  // FUNCTIONS
  Future<Result<void>> _requestSignUp(
    ({String email, String password}) commands,
  ) async {
    final result = await _authRepository.requestSignUp(
      email: commands.email,
      password: commands.password,
    );

    if (result is Error<void>) {
      _log.warning('Sign up failed! ${result.error}');
    }
    _log.info('Sign up result: $result');
    return result;
  }
}
