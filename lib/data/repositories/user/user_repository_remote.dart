import 'package:huzur_islamda/data/repositories/user/user_repository.dart';
import 'package:huzur_islamda/data/services/firestore_user_service.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class UserRepositoryRemote extends UserRepository {
  UserRepositoryRemote({required FirestoreUserService firestoreUserService})
    : _firestoreUserService = firestoreUserService;

  final FirestoreUserService _firestoreUserService;

  @override
  Future<Result<void>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
  }) async {
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
          return Result.ok(null);
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
  Future<Result<Consumer>> getUser(String uid) async {
    try {
      final result = await _firestoreUserService.getUser(uid);
      switch (result) {
        case Ok():
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<void>> deleteUser(String uid) async {
    try {
      final result = await _firestoreUserService.deleteUser(uid);
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
}
