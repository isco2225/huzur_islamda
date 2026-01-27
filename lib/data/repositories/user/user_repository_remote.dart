import 'package:flutter/foundation.dart';
import 'package:huzur_islamda/data/repositories/user/user_repository.dart';
import 'package:huzur_islamda/data/services/firestore_user_service.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class UserRepositoryRemote extends UserRepository {
  UserRepositoryRemote({required FirestoreUserService firestoreUserService})
    : _firestoreUserService = firestoreUserService;

  final FirestoreUserService _firestoreUserService;

  @override
  ValueListenable<User> get currentUser => _currentUser;
  final ValueNotifier<User> _currentUser = ValueNotifier<User>(User.empty());

  @override
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
  }) async {
    if (name.isEmpty ||
        surname.isEmpty ||
        dateOfBirth.isEmpty ||
        maritalStatus.isEmpty) {
      return Result.error(
        Exception(
          'Name, surname, date of birth and marital status are required',
        ),
      );
    }
    try {
      final result = await _firestoreUserService.createUser(
        uid: uid,
        email: email,
        name: name,
        surname: surname,
        dateOfBirth: dateOfBirth,
        maritalStatus: maritalStatus,
      );
      switch (result) {
        case Ok():
          _currentUser.value = result.asOk.value;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<bool>> initUser({required String uid}) async {
    try {
      final result = await _firestoreUserService.readAuthenticatedUser(
        uid: uid,
      );
      switch (result) {
        case Ok():
          if (result.asOk.value == null) {
            // Firestore'da kullanıcı bulunamadı, ancak Firebase Auth'da giriş yapmış
            // Bu durumda uid'yi dolu tutarak bir User objesi oluşturuyoruz
            // Böylece router doğru şekilde createProfile'e yönlendirebilir
            // Email boş bırakılabilir çünkü router'da email kontrolü yok, sadece uid kontrolü var
            _currentUser.value = User(
              uid: uid,
              email: '',
              name: '',
              surname: '',
              dateOfBirth: '',
              maritalStatus: '',
              emailVerified: false,
              createdAt: null,
              updatedAt: null,
              isRegistered: false,
              country: null,
              city: null,
              districtId: null,
            );
            return Result.ok(false);
          } else {
            _currentUser.value = result.asOk.value!;
            return Result.ok(true);
          }
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<void>> updateEmailVerificationStatus({
    required String uid,
    required bool emailVerified,
  }) async {
    try {
      final result = await _firestoreUserService.updateEmailVerificationStatus(
        uid: uid,
        emailVerified: emailVerified,
      );
      switch (result) {
        case Ok():
          _currentUser.value = _currentUser.value.copyWith(
            emailVerified: emailVerified,
          );
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<void>> updateUser({
    required String uid,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? maritalStatus,
  }) async {
    try {
      final result = await _firestoreUserService.updateUser(
        uid: uid,
        name: name,
        surname: surname,
        dateOfBirth: dateOfBirth,
        maritalStatus: maritalStatus,
      );
      switch (result) {
        case Ok():
          _currentUser.value = _currentUser.value.copyWith(
            name: name ?? _currentUser.value.name,
            surname: surname ?? _currentUser.value.surname,
            dateOfBirth: dateOfBirth ?? _currentUser.value.dateOfBirth,
            maritalStatus: maritalStatus ?? _currentUser.value.maritalStatus,
          );
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<bool>> fetchAuthenticatedUser({required String uid}) async {
    try {
      final result = await _firestoreUserService.readAuthenticatedUser(
        uid: uid,
      );
      switch (result) {
        case Ok():
          if (result.asOk.value != null) {
            _currentUser.value = result.asOk.value!;
            return Result.ok(true);
          } else {
            _currentUser.value = User.empty();
            return Result.ok(false);
          }
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<void>> deleteAuthenticatedUser({required String uid}) async {
    try {
      final result = await _firestoreUserService.deleteAuthenticatedUser(
        uid: uid,
      );
      switch (result) {
        case Ok():
          _currentUser.value = User.empty();
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  void wipeUser() {
    _currentUser.value = User.empty();
  }

  @override
  Future<Result<void>> updateUserLocation({
    required String uid,
    required String country,
    required String city,
    required String districtId,
  }) async {
    try {
      final result = await _firestoreUserService.updateUserLocation(
        uid: uid,
        country: country,
        city: city,
        districtId: districtId,
      );
      switch (result) {
        case Ok():
          if (result.asOk.value != null) {
            _currentUser.value = _currentUser.value.copyWith(
              country: country,
              city: city,
              districtId: districtId,
            );
            return Result.ok(null);
          } else {
            return Result.error(Exception('User not found on firestore'));
          }
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to update user location: $e'));
    }
  }

  @override
  Future<Result<List<String>?>> getFavoritedPostIds({
    required String uid,
  }) async {
    try {
      final result = await _firestoreUserService.getFavoritedPostIds(uid: uid);
      switch (result) {
        case Ok():
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to get favorited post ids: $e'));
    }
  }
}
