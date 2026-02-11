import 'package:flutter/foundation.dart';
import 'package:huzur_islamda/data/repositories/auth/auth_repository.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../services/services.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required FirebaseAuthService firebaseAuthService,
    required FirebaseCloudFunctionsService firebaseCloudFunctionsService,
  }) : _firebaseAuthService = firebaseAuthService,
       _firebaseCloudFunctionsService = firebaseCloudFunctionsService {
    // Initialize auth state by checking current user on app startup
    _initializeAuthState();
  }

  final FirebaseAuthService _firebaseAuthService;
  final FirebaseCloudFunctionsService _firebaseCloudFunctionsService;

  /// Initialize auth state by checking Firebase Auth current user
  void _initializeAuthState() {
    final currentUser = _firebaseAuthService.getCurrentUser();
    if (currentUser != null) {
      _auth.value = Auth(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        isEmailVerified: currentUser.emailVerified,
      );
      _isSignedIn.value = true;
    } else {
      _auth.value = Auth.empty();
      _isSignedIn.value = false;
    }
  }

  @override
  ValueListenable<Auth> get auth => _auth;
  final ValueNotifier<Auth> _auth = ValueNotifier<Auth>(Auth.empty());
  @override
  ValueListenable<bool> get isSignedIn => _isSignedIn;
  final ValueNotifier<bool> _isSignedIn = ValueNotifier<bool>(false);

  @override
  Future<Result> signIn({
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
          // Manually update auth state after successful sign in
          _auth.value = result.asOk.value;
          _isSignedIn.value = true;
          return Result.ok(result.asOk.value);
        case Error():
          _isSignedIn.value = false;
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result> signInWithGoogle() async {
    try {
      final result = await _firebaseAuthService.signInWithGoogle();
      switch (result) {
        case Ok():
          // Manually update auth state after successful sign in
          _auth.value = result.asOk.value;
          _isSignedIn.value = true;
          return Result.ok(result.asOk.value);
        case Error():
          _isSignedIn.value = false;
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result> requestSignUp({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      switch (result) {
        case Ok():
          // Manually update auth state after successful sign up
          _auth.value = result.asOk.value;
          _isSignedIn.value = true;
          return Result.ok(result.asOk.value);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
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
          final isEmailVerified = result.asOk.value;
          // Auth modelini güncelle (emailVerified durumunu yansıt)
          if (_auth.value.uid.isNotEmpty) {
            _auth.value = _auth.value.copyWith(
              isEmailVerified: isEmailVerified,
            );
          }
          return Result.ok(isEmailVerified);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result> signOut() async {
    try {
      final result = await _firebaseAuthService.signOut();
      switch (result) {
        case Ok():
          // Manually update auth state after successful sign out
          _auth.value = Auth.empty();
          _isSignedIn.value = false;
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result> deleteAccount() async {
    try {
      final result = await _firebaseCloudFunctionsService.deleteUserAccount();
      switch (result) {
        case Ok():
          // Manually update auth state after successful delete account
          _auth.value = Auth.empty();
          _isSignedIn.value = false;
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }

  @override
  Future<Result> reauthenticate() async {
    try {
      final currentUser = _firebaseAuthService.getCurrentUser();
      if (currentUser == null) {
        return Result.error(Exception('No user is currently signed in'));
      }

      final providerIds = currentUser.providerData
          .map((p) => p.providerId)
          .toList();

      AuthProviderType providerType = AuthProviderType.emailPassword;
      if (providerIds.contains('google.com')) {
        providerType = AuthProviderType.google;
      }

      switch (providerType) {
        case AuthProviderType.google:
          final result = await _firebaseAuthService.reauthenticateWithGoogle();
          switch (result) {
            case Ok():
              return Result.ok(null);
            case Error():
              return Result.error(result.asError.error);
          }
        case AuthProviderType.emailPassword:
          return Result.error(
            Exception(
              'Bu işlem için yeniden giriş yapmanız gerekiyor. Lütfen çıkış yapıp tekrar giriş yapın.',
            ),
          );
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }
}
