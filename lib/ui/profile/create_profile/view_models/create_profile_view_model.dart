import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/domain.dart';

class CreateProfileViewModel {
  CreateProfileViewModel({required AuthRepository authRepository})
    : _createUserProfileUseCase = CreateUserProfileUseCase(
        userRepository: context.read<UserRepository>(),
        authRepository: context.read<AuthRepository>(),
      ) {
    // DEFINE COMMANDS
    createUserProfile =
        Command1<
          void,
          ({
            String name,
            String surname,
            String dateOfBirth,
            String maritalStatus,
          })
        >(_createUserProfile, debugLabel: 'createUserProfile');

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('ProfileViewModel');

  // REPOSITORIES & USE CASES
  final CreateUserProfileUseCase _createUserProfileUseCase;
  // DOMAIN

  // COMMANDS
  late final Command1<
    void,
    ({String name, String surname, String dateOfBirth, String maritalStatus})
  >
  createUserProfile;

  // DISPOSE
  void dispose() {
    createUserProfile.dispose();
  }

  // FUNCTIONS
  Future<Result<void>> _createUserProfile(
    ({String name, String surname, String dateOfBirth, String maritalStatus})
    commands,
  ) async {
    try {
      final result = await _createUserProfileUseCase.execute(
        name: commands.name,
        surname: commands.surname,
        dateOfBirth: commands.dateOfBirth,
        maritalStatus: commands.maritalStatus,
      );
      switch (result) {
        case Ok():
          _log.info('User profile created successfully');
          return Result.ok(null);
        case Error():
          _log.warning(
            'User profile creation failed: ${result.asError.error.toString()}',
          );
          return Result.error(result.asError.error);
      }
    } catch (e) {
      _log.severe('Unexpected error in createUserProfile: $e');
      return Result.error(Exception(e));
    }
  }
}
