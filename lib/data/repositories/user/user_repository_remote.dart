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
    required String gender,
  }) async {
    if (name.isEmpty || surname.isEmpty || gender.isEmpty) {
      return Result.error(
        Exception('Ad, soyad ve cinsiyet zorunludur'),
      );
    }
    try {
      final result = await _firestoreUserService.createUser(
        uid: uid,
        email: email,
        name: name,
        surname: surname,
        dateOfBirth: dateOfBirth,
        gender: gender,
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
              gender: '',
              emailVerified: false,
              createdAt: null,
              updatedAt: null,
              isRegistered: false,
              country: null,
              city: null,
              districtId: null,
              lastSupportedAt: null,
              supportPackage: null,
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
    String? gender,
  }) async {
    try {
      final result = await _firestoreUserService.updateUser(
        uid: uid,
        name: name,
        surname: surname,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      switch (result) {
        case Ok():
          _currentUser.value = _currentUser.value.copyWith(
            name: name ?? _currentUser.value.name,
            surname: surname ?? _currentUser.value.surname,
            dateOfBirth: dateOfBirth ?? _currentUser.value.dateOfBirth,
            gender: gender ?? _currentUser.value.gender,
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

  @override
  Future<Result<void>> updateUserPremium({
    required String uid,
    required DateTime lastPremiumAt,
    required SupportPackage supportPackage,
  }) async {
    try {
      final result = await _firestoreUserService.updateUserPremium(
        uid: uid,
        lastPremiumAt: lastPremiumAt,
        supportPackage: supportPackage.value,
      );
      switch (result) {
        case Ok():
          final updatedUser = result.asOk.value;
          if (updatedUser != null) {
            _currentUser.value = updatedUser;
          } else {
            _currentUser.value = _currentUser.value.copyWith(
              lastSupportedAt: lastPremiumAt,
              supportPackage: supportPackage,
            );
          }
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to update user premium: $e'));
    }
  }

  /*Future<Result<void>> updateUserSupport({
    required String uid,
    required bool hasSupported,
    required DateTime lastSupportedAt,
    required SupportPackage supportPackage,
  }) async {
    try {
      final result = await _firestoreUserService.updateUserSupport(
        uid: uid,
        hasSupported: hasSupported,
        lastSupportedAt: lastSupportedAt,
        supportPackage: supportPackage.value,
      );
      switch (result) {
        case Ok():
          final updatedUser = result.asOk.value;
          if (updatedUser != null) {
            _currentUser.value = updatedUser;
          } else {
            _currentUser.value = _currentUser.value.copyWith(
              hasSupported: hasSupported,
              lastSupportedAt: lastSupportedAt,
              supportPackage: supportPackage,
            );
          }
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Failed to update user support: $e'));
    }
  }*/
}
