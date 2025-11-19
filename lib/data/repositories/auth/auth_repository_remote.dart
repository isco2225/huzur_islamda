import 'package:flutter/foundation.dart';
import 'package:huzur_islamda/data/repositories/auth/auth_repository.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../services/services.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({required FirebaseAuthService firebaseAuthService})
    : _firebaseAuthService = firebaseAuthService;

  final FirebaseAuthService _firebaseAuthService;

  @override
  ValueListenable<String?> get currentUserEmail => _currentUserEmail;
  final ValueNotifier<String?> _currentUserEmail = ValueNotifier<String?>(null);

  @override
  ValueListenable<String?> get currentUserId => _currentUserId;
  final ValueNotifier<String?> _currentUserId = ValueNotifier<String?>(null);

  @override
  Future<Result<Consumer>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
  Future<Result<Consumer>> requestSignUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
  }) async {
    try {
      final result = await _firebaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      switch (result) {
        case Ok():
          _currentUserEmail.value = result.asOk.value.email;
          _currentUserId.value = result.asOk.value.uid;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<Consumer>> createAccount({
    required String email,
    required String verificationCode,
  }) {
    // TODO: implement createAccount
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> sendPasswordResetCode({required String email}) {
    // TODO: implement sendPasswordResetCode
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      final result = await _firebaseAuthService.sendEmailVerification();
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
  Future<Result<bool>> checkEmailVerification() async {
    try {
      final result = await _firebaseAuthService.checkEmailVerification();
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
  Future<Result<void>> signOut() async {
    try {
      final result = await _firebaseAuthService.signOut();
      switch (result) {
        case Ok():
          _currentUserEmail.value = null;
          _currentUserId.value = null;
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final result = await _firebaseAuthService.deleteAccount();
      switch (result) {
        case Ok():
          _currentUserEmail.value = null;
          _currentUserId.value = null;
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }
}
