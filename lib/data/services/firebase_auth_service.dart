import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirebaseAuthService {
  final _log = Logger('FirebaseAuthService');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _isGoogleSignInInitialized = false;

  static Future<void> initializeGoogleSignIn() async {
    if (_isGoogleSignInInitialized) return;
    await _googleSignIn.initialize(
      serverClientId:
          '418329675000-f4eb2vigvvn0j5v0dm4mcn63c2494tdb.apps.googleusercontent.com',
    );
    _isGoogleSignInInitialized = true;
  }

  /// Get current user from Firebase Auth
  /// Returns null if no user is signed in
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

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
        return Result.error(const AuthSignUpFailed());
      }
      return Result.ok(
        Auth(uid: user.uid, email: email, isEmailVerified: user.emailVerified),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return Result.error(const AuthUserAlreadyExists());
      }
      return Result.error(const AuthSignUpFailed());
    } catch (_) {
      return Result.error(const AuthSignUpFailed());
    }
  }

  /// Sign in with Google
  Future<Result<Auth>> signInWithGoogle() async {
    try {
      await initializeGoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final authorizationClient = googleUser.authorizationClient;
      final authorization = await authorizationClient.authorizationForScopes([
        'email',
        'profile',
      ]);
      if (authorization == null) {
        _log.warning('Google sign-in: no authorization for email/profile');
        return Result.error(const AuthGoogleSignInFailed());
      }

      if (googleAuth.idToken == null) {
        _log.warning('Google sign-in: account returned no idToken');
        return Result.error(const AuthGoogleSignInFailed());
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        _log.warning('Google sign-in: Firebase returned no user');
        return Result.error(const AuthGoogleSignInFailed());
      }
      return Result.ok(
        Auth(
          uid: user.uid,
          email: user.email ?? user.providerData.first.email ?? '',
          isEmailVerified: user.emailVerified,
        ),
      );
    } on GoogleSignInException catch (e, stackTrace) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        _log.info('Google sign-in cancelled by the user');
        return Result.error(
          const UserMessageException('Google ile giriş iptal edildi'),
        );
      }
      // Configuration problems (client id / URL scheme / bundle id mismatch)
      // surface here as clientConfigurationError or providerConfigurationError.
      _log.severe(
        'Google sign-in failed: ${e.code} ${e.description ?? ''}',
        e,
        stackTrace,
      );
      return Result.error(const AuthGoogleSignInFailed());
    } on FirebaseAuthException catch (e, stackTrace) {
      _log.severe('Google sign-in Firebase error: ${e.code}', e, stackTrace);
      return Result.error(const AuthGoogleSignInFailed());
    } catch (e, stackTrace) {
      _log.severe('Google sign-in unexpected error', e, stackTrace);
      return Result.error(const AuthGoogleSignInFailed());
    }
  }

  /// Sign in with Apple
  Future<Result<Auth>> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      if (appleCredential.identityToken == null) {
        return Result.error(const AuthAppleSignInFailed());
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user == null) {
        return Result.error(const AuthAppleSignInFailed());
      }

      String email = user.email ?? appleCredential.email ?? '';
      if (email.isEmpty) {
        final providerWithEmail = user.providerData
            .where((p) => p.email != null && p.email!.isNotEmpty)
            .firstOrNull;
        email = providerWithEmail?.email ?? '';
      }

      return Result.ok(
        Auth(uid: user.uid, email: email, isEmailVerified: user.emailVerified),
      );
    } on SignInWithAppleAuthorizationException catch (e, stackTrace) {
      if (e.code == AuthorizationErrorCode.canceled) {
        _log.info('Apple sign-in cancelled by the user');
        return Result.error(
          const UserMessageException('Apple ile giriş iptal edildi'),
        );
      }
      _log.severe(
        'Apple sign-in failed: ${e.code} ${e.message}',
        e,
        stackTrace,
      );
      return Result.error(const AuthAppleSignInFailed());
    } on SignInWithAppleNotSupportedException catch (e, stackTrace) {
      _log.severe('Apple sign-in not supported on this device', e, stackTrace);
      return Result.error(const AuthAppleSignInFailed());
    } on FirebaseAuthException catch (e, stackTrace) {
      _log.severe('Apple sign-in Firebase error: ${e.code}', e, stackTrace);
      return Result.error(const AuthAppleSignInFailed());
    } catch (e, stackTrace) {
      _log.severe('Apple sign-in unexpected error', e, stackTrace);
      return Result.error(const AuthAppleSignInFailed());
    }
  }

  String _generateNonce([int length = 32]) {
    return generateNonce(length: length);
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Send link to the user email address for email verification
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }

      if (user.emailVerified) {
        return Result.error(const AuthEmailAlreadyVerified());
      }

      await user.sendEmailVerification();
      return Result.ok(null);
    } on FirebaseAuthException catch (_) {
      return Result.error(const AuthSendVerificationEmailFailed());
    } catch (_) {
      return Result.error(const AuthSendVerificationEmailFailed());
    }
  }

  /// Check if the user's email is verified
  Future<Result<bool>> checkEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser == null) {
        return Result.error(const AuthCheckEmailVerificationFailed());
      }

      return Result.ok(refreshedUser.emailVerified);
    } on FirebaseAuthException catch (_) {
      return Result.error(const AuthCheckEmailVerificationFailed());
    } catch (_) {
      return Result.error(const AuthCheckEmailVerificationFailed());
    }
  }

  /// Send password reset email to the given email address
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    if (email.isEmpty) {
      return Result.error(const AuthUserEmailNotFound());
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.ok(null);
    } on FirebaseAuthException catch (_) {
      return Result.error(const AuthSendPasswordResetEmailFailed());
    } catch (_) {
      return Result.error(const AuthSendPasswordResetEmailFailed());
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
        return Result.error(const AuthUserEmailNotFound());
      }
      return Result.ok(
        Auth(
          uid: auth.uid,
          email: auth.email ?? email,
          isEmailVerified: auth.emailVerified,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Result.error(const AuthUserEmailNotFound());
      }
      if (e.code == 'invalid-credential') {
        return Result.error(const AuthUserEmailNotFound());
      }
      return Result.error(const AuthSignInFailed());
    } catch (_) {
      return Result.error(const AuthSignInFailed());
    }
  }

  /// Sign out the current user
  Future<Result<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
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
        return Result.error(const AuthNoUserSignedIn());
      }
      await user.delete();
      await _googleSignIn.signOut();
      return Result.ok(null);
    } on FirebaseAuthException catch (_) {
      return Result.error(const AuthDeleteAccountFailed());
    } catch (_) {
      return Result.error(const AuthDeleteAccountFailed());
    }
  }

  Future<Result<void>> reauthenticateWithEmail({
    required String password,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }
      final email = user.email;
      if (email == null || email.isEmpty) {
        return Result.error(const AuthUserEmailNotFound());
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      _log.warning('Firebase auth error: ${e.code}');
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return Result.error(const AuthChangePasswordFailed());
      }
      return Result.error(Exception(e.message ?? e.code));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  /// Requires the current password for reauthentication.
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty) {
      return Result.error(const AuthChangePasswordFailed());
    }
    if (newPassword.isEmpty) {
      return Result.error(const AuthChangePasswordFailed());
    }
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }
      final email = user.email;
      if (email == null || email.isEmpty) {
        return Result.error(const AuthUserEmailNotFound());
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return Result.ok(null);
    } on FirebaseAuthException catch (e) {
      _log.warning('Firebase auth error: ${e.code}');
      if (e.code == 'requires-recent-login') {
        return Result.error(const AuthChangePasswordFailed());
      }
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return Result.error(const AuthChangePasswordFailed());
      }
      if (e.code == 'weak-password') {
        return Result.error(const AuthChangePasswordFailed());
      }
      return Result.error(const AuthChangePasswordFailed());
    } catch (_) {
      return Result.error(const AuthChangePasswordFailed());
    }
  }

  Future<Result<void>> reauthenticateWithGoogle() async {
    try {
      await initializeGoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final authorizationClient = googleUser.authorizationClient;
      final authorization = await authorizationClient.authorizationForScopes([
        'email',
        'profile',
      ]);
      if (authorization == null || googleAuth.idToken == null) {
        return Result.error(const AuthGoogleSignInFailed());
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }
      await user.reauthenticateWithCredential(credential);
      return Result.ok(null);
    } on FirebaseAuthException catch (_) {
      return Result.error(Exception('abnormal reauthentication with google'));
    } catch (_) {
      return Result.error(Exception('abnormal reauthentication with google'));
    }
  }

  Future<Result<void>> reauthenticateWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      if (appleCredential.identityToken == null) {
        return Result.error(const AuthAppleSignInFailed());
      }

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }
      await user.reauthenticateWithCredential(oauthCredential);
      return Result.ok(null);
    } on SignInWithAppleAuthorizationException catch (_) {
      return Result.error(const AuthAppleSignInFailed());
    } on SignInWithAppleNotSupportedException {
      return Result.error(const AuthAppleSignInFailed());
    } on FirebaseAuthException catch (_) {
      return Result.error(Exception('abnormal reauthentication with apple'));
    } catch (_) {
      return Result.error(Exception('abnormal reauthentication with apple'));
    }
  }

  /// refresh the current user(Not used for now)
  Future<Result<void>> refreshUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.error(const AuthNoUserSignedIn());
      }
      await user.reload();
      return Result.ok(null);
    } on FirebaseAuthException catch (_) {
      return Result.error(const AuthCheckEmailVerificationFailed());
    } catch (_) {
      return Result.error(const AuthCheckEmailVerificationFailed());
    }
  }
}
