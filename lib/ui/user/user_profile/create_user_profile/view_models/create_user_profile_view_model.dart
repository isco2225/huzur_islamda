import 'package:logging/logging.dart';

import '../../../../../app/app.dart';
import '../../../../../domain/domain.dart';

class CreateUserProfileViewModel {
  CreateUserProfileViewModel({
    required CreateUserProfileUseCase createUserProfileUseCase,
  }) : _createUserProfileUseCase = createUserProfileUseCase {
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
  final _log = Logger('CreateUserProfileViewModel');

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
    final result = await _createUserProfileUseCase.execute(
      name: commands.name,
      surname: commands.surname,
      dateOfBirth: commands.dateOfBirth,
      maritalStatus: commands.maritalStatus,
    );
    _log.info('Create profile result: $result');
    return result;
  }
}
