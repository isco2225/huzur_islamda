import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class CreateProfileViewModel {
  CreateProfileViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
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
  final AuthRepository _authRepository;
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
    return Result.ok(null);
  }
}
