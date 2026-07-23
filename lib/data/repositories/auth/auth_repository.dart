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

  /// Perform Sign In with Apple
  Future<Result> signInWithApple();

  /// Perform create account request
  Future<Result> requestSignUp({
    required String email,
    required String password,
  });

  /// Send password reset email to the given email address
  Future<Result<void>> sendPasswordResetEmail({required String email});

  /// Send email verification to current user
  Future<Result<void>> sendEmailVerification();

  /// Check if current user's email is verified
  Future<Result<bool>> checkEmailVerification();

  /// Perform sign out
  Future<Result> signOut();

  /// Delete current user account
  Future<Result> deleteAccount();

  /// Update current user password.
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Reauthenticate current user
  Future<Result> reauthenticate();
}
