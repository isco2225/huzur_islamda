import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class AuthRepository {
  /// Perform Sign In
  Future<Result<Consumer>> signIn({
    required String email,
    required String password,
  });

  /// Perform create account request
  Future<Result<Consumer>> requestSignUp({
    required String email,
    required String password,
  });

  /// Perform sign up with code
  Future<Result<Consumer>> createAccount({
    required String email,
    required String verificationCode,
  });

  /// Perform send password reset code
  Future<Result<void>> sendPasswordResetCode({required String email});

  /// Perform sign out
  Future<Result<void>> signOut();
}
