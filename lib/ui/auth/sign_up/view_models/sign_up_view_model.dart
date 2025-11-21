import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/repositories/auth/auth_repository.dart';

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

    return result;
  }
}
