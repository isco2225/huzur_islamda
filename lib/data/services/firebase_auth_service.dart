import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up with email and password
  Future<Result<Auth>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;
      if (user == null) {
        return Result.error(Exception('Failed to sign up'));
      }
      return Result.ok(
        Auth(uid: user.uid, email: email, isEmailVerified: user.emailVerified),
      );
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Failed to sign up: ${e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to sign up: $e'));
    }
  }

  /// Send link to the user email address for email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(Exception('No user is currently signed in'));
      }

      if (user.emailVerified) {
        return Result.error(Exception('Email is already verified'));
      }

      await user.sendEmailVerification();
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Failed to send verification email'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to send verification email: $e'));
    }
  }

  /// Check if the user's email is verified
  Future<Result<bool>> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(Exception('No user is currently signed in'));
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return Result.error(Exception('User not found after reload'));
      }

      return Result.ok(refreshedUser.emailVerified);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Failed to check email verification'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to check email verification: $e'));
    }
  }

  /// Sign in with email and password
  Future<Result<Auth>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final auth = result.user;
      if (auth == null) {
        return Result.error(Exception('Failed to sign in'));
      }
      return Result.ok(
        Auth(uid: auth.uid, email: email, isEmailVerified: auth.emailVerified),
      );
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Failed to sign in: ${e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to sign in: $e'));
    }
  }

  /// Sign out the current user
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to sign out: $e'));
    }
  }

  /// Delete the current user account
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(Exception('No user is currently signed in'));
      }

      await user.delete();
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Failed to delete account: ${e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to delete account: $e'));
    }
  }

  /// refresh the current user
  Future<Result<void>> refreshUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(Exception('No user is currently signed in'));
      }
      await user.reload();
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      return Result.error(
        Exception(e.message ?? 'Failed to refresh user: ${e.code}'),
      );
    } catch (e) {
      return Result.error(Exception('Failed to refresh user: $e'));
    }
  }
}
