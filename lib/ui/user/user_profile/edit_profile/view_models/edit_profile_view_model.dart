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
    updateUserLocation = Command1(
      _updateUserLocation,
      debugLabel: 'EditProfileViewModel.updateUserLocation',
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

  late Command1<void, ({String districtId, String city, String country})>
  updateUserLocation;

  // DISPOSE
  void dispose() {
    updateProfile.dispose();
    updateUserLocation.dispose();
    _log.fine('EditProfileViewModel Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _updateProfile(
    ({
      String? name,
      String? surname,
      String? dateOfBirth,
      String? maritalStatus,
    })
    arguments,
  ) async {
    // check if no changes are made
    if (arguments.name == currentUser.value.name &&
        arguments.surname == currentUser.value.surname &&
        arguments.dateOfBirth == currentUser.value.dateOfBirth &&
        arguments.maritalStatus == currentUser.value.maritalStatus) {
      return Result.ok(null);
    }
    final result = await _userRepository.updateUser(
      uid: currentUser.value.uid,
      name: arguments.name,
      surname: arguments.surname,
      dateOfBirth: arguments.dateOfBirth,
      maritalStatus: arguments.maritalStatus,
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

  Future<Result<void>> _updateUserLocation(
    ({String districtId, String city, String country}) arguments,
  ) async {
    final result = await _userRepository.updateUserLocation(
      uid: currentUser.value.uid,
      country: arguments.country,
      city: arguments.city,
      districtId: arguments.districtId,
    );
    switch (result) {
      case Ok():
        _log.info('User location updated successfully');
        return result;
      case Error():
        _log.warning('Failed to update user location', result.error);
        return result;
    }
  }
}
