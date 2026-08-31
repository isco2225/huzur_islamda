import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../../app/app.dart';
import '../../../../../data/data.dart';
import '../../../../../domain/domain.dart';

class EditProfileViewModel {
  EditProfileViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required AppRepository appRepository,
    required SchedulePrayerNotificationsUseCase
    schedulePrayerNotificationsUseCase,
  }) : _userRepository = userRepository,
       _appRepository = appRepository,
       _schedulePrayerNotificationsUseCase = schedulePrayerNotificationsUseCase,
       _isNotificationsEnabled = ValueNotifier<bool>(
         appRepository.appPreferences.value.isNotificationsEnabled,
       ),
       _currentUserName = ValueNotifier<String>(
         userRepository.currentUser.value.name,
       ),
       _currentUserSurname = ValueNotifier<String>(
         userRepository.currentUser.value.surname,
       ),
       _currentUserDateOfBirth = ValueNotifier<String>(
         userRepository.currentUser.value.dateOfBirth,
       ),
       _currentUserGender = ValueNotifier<String>(
         userRepository.currentUser.value.gender,
       ) {
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
    _appRepository.appPreferences.addListener(_onAppPreferencesChanged);
    _userRepository.currentUser.addListener(_onCurrentUserChanged);
  }

  // LOGGER
  final _log = Logger('EditProfileViewModel');

  // REPOSITORIES & USE CASES
  final UserRepository _userRepository;
  final AppRepository _appRepository;
  final SchedulePrayerNotificationsUseCase _schedulePrayerNotificationsUseCase;
  // DOMAIN
  ValueListenable<User> get currentUser => _userRepository.currentUser;

  ValueListenable<String> get currentUserName => _currentUserName;
  ValueListenable<String> get currentUserSurname => _currentUserSurname;
  ValueListenable<String> get currentUserDateOfBirth => _currentUserDateOfBirth;
  ValueListenable<String> get currentUserGender => _currentUserGender;

  final ValueNotifier<String> _currentUserName;
  final ValueNotifier<String> _currentUserSurname;
  final ValueNotifier<String> _currentUserDateOfBirth;
  final ValueNotifier<String> _currentUserGender;

  final ValueNotifier<bool> _isNotificationsEnabled;

  // COMMANDS
  late Command1<
    void,
    ({String? name, String? surname, String? dateOfBirth, String? gender})
  >
  updateProfile;

  late Command1<void, ({String districtId, String city, String country})>
  updateUserLocation;

  // DISPOSE
  void dispose() {
    updateProfile.dispose();
    updateUserLocation.dispose();
    _isNotificationsEnabled.dispose();
    _appRepository.appPreferences.removeListener(_onAppPreferencesChanged);
    _userRepository.currentUser.removeListener(_onCurrentUserChanged);
    _currentUserName.dispose();
    _currentUserSurname.dispose();
    _currentUserDateOfBirth.dispose();
    _currentUserGender.dispose();
    _log.fine('EditProfileViewModel Disposed');
  }

  // FUNCTIONS
  Future<Result<void>> _updateProfile(
    ({String? name, String? surname, String? dateOfBirth, String? gender})
    arguments,
  ) async {
    // check if no changes are made
    if (arguments.name == currentUser.value.name &&
        arguments.surname == currentUser.value.surname &&
        arguments.dateOfBirth == currentUser.value.dateOfBirth &&
        arguments.gender == currentUser.value.gender) {
      return Result.ok(null);
    }
    final result = await _userRepository.updateUser(
      uid: currentUser.value.uid,
      name: arguments.name,
      surname: arguments.surname,
      dateOfBirth: arguments.dateOfBirth,
      gender: arguments.gender,
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
        if (_isNotificationsEnabled.value) {
          final scheduleResult = await _schedulePrayerNotificationsUseCase
              .scheduleForWeek();
          switch (scheduleResult) {
            case Ok():
              _log.info('Prayer notifications scheduled successfully');
              break;
            case Error():
              _log.warning(
                'Failed to schedule prayer notifications',
                scheduleResult.error,
              );
          }
        }
        _log.info('User location updated successfully');
        return result;
      case Error():
        _log.warning('Failed to update user location', result.error);
        return result;
    }
  }

  void _onAppPreferencesChanged() {
    _isNotificationsEnabled.value =
        _appRepository.appPreferences.value.isNotificationsEnabled;
  }

  void _onCurrentUserChanged() {
    final user = currentUser.value;
    _currentUserName.value = user.name;
    _currentUserSurname.value = user.surname;
    _currentUserDateOfBirth.value = user.dateOfBirth;
    _currentUserGender.value = user.gender;
  }
}
