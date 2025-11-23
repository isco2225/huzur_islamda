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
            updatedAt: DateTime.now(),
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
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<User>> fetchAuthenticatedUser({required String uid}) async {
    try {
      final result = await _firestoreUserService.fetchAuthenticatedUser(
        uid: uid,
      );
      switch (result) {
        case Ok():
          _currentUser.value = result.asOk.value;
          return Result.ok(result.asOk.value);
        case Error():
          _currentUser.value = User.empty();
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
}
