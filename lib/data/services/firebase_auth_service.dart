import 'package:firebase_auth/firebase_auth.dart' as firebase_auth show User;
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirebaseAuthService {
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
        return Result.error(const AuthGoogleSignInFailed());
      }

      if (googleAuth.idToken == null) {
        return Result.error(const AuthGoogleSignInFailed());
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return Result.error(const AuthGoogleSignInFailed());
      }
      return Result.ok(
        Auth(
          uid: user.uid,
          email: user.email ?? user.providerData.first.email ?? '',
          isEmailVerified: user.emailVerified,
        ),
      );
    } on FirebaseAuthException catch (_) {
      return Result.error(const AuthGoogleSignInFailed());
    } catch (_) {
      return Result.error(const AuthGoogleSignInFailed());
    }
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
    final user = _auth.currentUser;
    if (user == null) {
      return Result.error(const AuthNoUserSignedIn());
    }
    final email = user.email;
    if (email == null) {
      return Result.error(const AuthUserEmailNotFound());
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    return Result.ok(null);
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
