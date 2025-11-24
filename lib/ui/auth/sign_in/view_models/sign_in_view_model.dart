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
    // Sign in with Firebase Auth
    final signInResult = await _authRepository.signIn(
      email: commands.email,
      password: commands.password,
    );

    switch (signInResult) {
      case Ok():
        _log.info('Sign in successful');
        return Result.ok(null);
      case Error():
        _log.warning('Sign in failed: ${signInResult.asError.error}');
        return Result.error(signInResult.asError.error);
    }
  }
}
