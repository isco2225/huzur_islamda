import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class SignInViewModel {
  SignInViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    // DEFINE COMMANDS
    signIn = Command1(_signIn, debugLabel: 'signIn');

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('SignInViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

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
        _log.info('Sign in successful, fetching user from Firestore');
        // Sign in successful, fetch user from Firestore
        final auth = _authRepository.auth.value;
        if (auth.isSignedIn() && auth.uid.isNotEmpty) {
          final fetchResult = await _userRepository.fetchAuthenticatedUser(
            uid: auth.uid,
          );
          switch (fetchResult) {
            case Ok():
              _log.info('User fetched successfully from Firestore');
              return Result.ok(null);
            case Error():
              // User not found in Firestore (profile not created yet)
              // This is OK, user will be redirected to create profile
              _log.warning(
                'User not found in Firestore, profile needs to be created',
              );
              return Result.ok(null);
          }
        }
        return Result.ok(null);
      case Error():
        _log.warning('Sign in failed: ${signInResult.asError.error}');
        return Result.error(signInResult.asError.error);
    }
  }
}
