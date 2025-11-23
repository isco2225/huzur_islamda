import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class SignInViewModel {
  SignInViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // DEFINE COMMANDS
    signIn = Command1(_signIn, debugLabel: 'signIn');

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('SignInViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;

  // DOMAIN

  // COMMANDS
  late Command1<void, ({String email, String password})> signIn;

  // DISPOSE
  void dispose() {
    signIn.dispose();
  }

  // FUNCTIONS
  Future<Result<void>> _signIn(
    ({String email, String password}) commands,
  ) async {
    final result = await _authRepository.signIn(
      email: commands.email,
      password: commands.password,
    );
    _log.info('Sign in result: $result');
    return result;
  }
}
