import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class AuthRepository {
  /// Get current user
  ValueListenable<Auth> get auth;
  ValueListenable<bool> get isSignedIn;

  /// Perform Sign In
  Future<Result> signIn({required String email, required String password});

  /// Perform Sign In with Google
  Future<Result> signInWithGoogle();

  /// Perform create account request
  Future<Result> requestSignUp({
    required String email,
    required String password,
  });

  /// Perform send password reset code
  Future<Result<void>> sendPasswordResetCode({required String email});

  /// Send email verification to current user
  Future<Result<void>> sendEmailVerification();

  /// Check if current user's email is verified
  Future<Result<bool>> checkEmailVerification();

  /// Perform sign out
  Future<Result> signOut();

  /// Delete current user account
  Future<Result> deleteAccount();
}
