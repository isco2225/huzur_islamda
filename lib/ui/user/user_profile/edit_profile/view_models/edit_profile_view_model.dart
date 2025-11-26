import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../../app/app.dart';
import '../../../../../data/data.dart';
import '../../../../../domain/domain.dart';

class EditProfileViewModel {
  EditProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository {
    // DEFINE COMMANDS
    updateProfile = Command1(
      _updateProfile,
      debugLabel: 'EditProfileViewModel.updateProfile',
    );

    // DEFINE LISTENERS
  }

  // LOGGER
  final _log = Logger('EditProfileViewModel');

  // REPOSITORIES & USE CASES
  final UserRepository _userRepository;

  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;

  ValueListenable<String> get currentUserName =>
      ValueNotifier<String>(currentUser.value.name);
  ValueListenable<String> get currentUserSurname =>
      ValueNotifier<String>(currentUser.value.surname);
  ValueListenable<String> get currentUserDateOfBirth =>
      ValueNotifier<String>(currentUser.value.dateOfBirth);
  ValueListenable<String> get currentUserMaritalStatus =>
      ValueNotifier<String>(currentUser.value.maritalStatus);

  // COMMANDS
  late Command1<
    void,
    ({
      String? name,
      String? surname,
      String? dateOfBirth,
      String? maritalStatus,
    })
  >
  updateProfile;

  // DISPOSE
  void dispose() {
    updateProfile.dispose();
  }

  // FUNCTIONS
  Future<Result<void>> _updateProfile(
    ({
      String? name,
      String? surname,
      String? dateOfBirth,
      String? maritalStatus,
    })
    commands,
  ) async {
    final result = await _userRepository.updateUser(
      uid: currentUser.value.uid,
      name: commands.name,
      surname: commands.surname,
      dateOfBirth: commands.dateOfBirth,
      maritalStatus: commands.maritalStatus,
    );

    switch (result) {
      case Ok():
        _log.info('Profile updated successfully');
        return result;
      case Error():
        _log.warning('Failed to update profile', result.error);
        return result;
    }
  }
}
