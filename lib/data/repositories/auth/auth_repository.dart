import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class AuthRepository {
  /// Get current user's email
  ValueListenable<String?> get currentUserEmail;

  /// Get current user's UID
  ValueListenable<String?> get currentUserId;

  /// Perform Sign In
  Future<Result<Consumer>> signIn({
    required String email,
    required String password,
  });

  /// Perform create account request
  Future<Result<Consumer>> requestSignUp({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
  });

  /// Perform sign up with code
  Future<Result<Consumer>> createAccount({
    required String email,
    required String verificationCode,
  });

  /// Perform send password reset code
  Future<Result<void>> sendPasswordResetCode({required String email});

  /// Send email verification to current user
  Future<Result<void>> sendEmailVerification();

  /// Check if current user's email is verified
  Future<Result<bool>> checkEmailVerification();

  /// Perform sign out
  Future<Result<void>> signOut();
}
