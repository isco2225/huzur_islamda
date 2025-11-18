import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/repositories/auth/auth_repository.dart';
import '../../../../domain/consumer/use_cases/use_cases.dart';
import '../../../../domain/domain.dart';

class SignUpViewModel {
  SignUpViewModel({
    required SignUpUseCase signUpUseCase,
    required CheckEmailVerificationUseCase checkEmailVerificationUseCase,
    required AuthRepository authRepository,
  }) : _signUpUseCase = signUpUseCase,
       _checkEmailVerificationUseCase = checkEmailVerificationUseCase,
       _authRepository = authRepository {
    // DEFINE COMMANDS
    requestSignUp =
        Command1<
          Consumer,
          ({
            String email,
            String password,
            String name,
            String surname,
            String dateOfBirth,
            String maritalStatus,
          })
        >(_requestSignUp, debugLabel: 'requestSignUp');

    sendEmailVerification = Command0<void>(
      _sendEmailVerification,
      debugLabel: 'sendEmailVerification',
    );

    checkEmailVerification = Command0<bool>(
      _checkEmailVerification,
      debugLabel: 'checkEmailVerification',
    );

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('SignUpViewModel');

  // REPOSITORIES & USE CASES
  final SignUpUseCase _signUpUseCase;
  final CheckEmailVerificationUseCase _checkEmailVerificationUseCase;
  final AuthRepository _authRepository;

  // DOMAIN

  // COMMANDS
  late final Command1<
    Consumer,
    ({
      String email,
      String password,
      String name,
      String surname,
      String dateOfBirth,
      String maritalStatus,
    })
  >
  requestSignUp;
  late final Command0<void> sendEmailVerification;
  late final Command0<bool> checkEmailVerification;

  // DISPOSE
  void dispose() {
    requestSignUp.dispose();
    sendEmailVerification.dispose();
    checkEmailVerification.dispose();
  }

  // FUNCTIONS
  Future<Result<Consumer>> _requestSignUp(
    ({
      String email,
      String password,
      String name,
      String surname,
      String dateOfBirth,
      String maritalStatus,
    })
    commands,
  ) async {
    final result = await _signUpUseCase.execute(
      email: commands.email,
      password: commands.password,
      name: commands.name,
      surname: commands.surname,
      dateOfBirth: commands.dateOfBirth,
      maritalStatus: commands.maritalStatus,
    );

    if (result is Error<Consumer>) {
      _log.warning('Sign up failed! ${result.error}');
    }

    return result;
  }

  Future<Result<void>> _sendEmailVerification() async {
    final result = await _authRepository.sendEmailVerification();
    _log.info('Send email verification result: $result');

    if (result is Error<void>) {
      _log.warning('Send email verification failed! ${result.error}');
    }

    return result;
  }

  Future<Result<bool>> _checkEmailVerification() async {
    final result = await _checkEmailVerificationUseCase.execute();
    _log.info('Check email verification result: $result');
    if (result is Error<bool>) {
      _log.warning('Check email verification failed! ${result.error}');
    }

    return result;
  }
}
