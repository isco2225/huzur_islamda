import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

/// The fake auth service always reports no current Firebase user (a
/// `firebase_auth.User` cannot be built in tests), so the "restored session
/// at startup" branch and the provider detection inside `reauthenticate` are
/// not reachable here.
void main() {
  late FakeFirebaseAuthService authService;
  late FakeFirebaseCloudFunctionsService functionsService;
  late AuthRepositoryRemote repository;

  setUp(() {
    authService = FakeFirebaseAuthService();
    functionsService = FakeFirebaseCloudFunctionsService();
    repository = AuthRepositoryRemote(
      firebaseAuthService: authService,
      firebaseCloudFunctionsService: functionsService,
    );
  });

  Future<void> signInAs(Auth auth) async {
    authService.signInResult = Result.ok(auth);
    await repository.signIn(email: auth.email, password: 'pw');
  }

  test('construction reads the current user once and starts signed out', () {
    expect(authService.getCurrentUserCount, 1);
    expect(repository.auth.value.uid, '');
    expect(repository.auth.value.isSignedIn(), isFalse);
    expect(repository.isSignedIn.value, isFalse);
  });

  group('signIn', () {
    test('publishes the auth and flips isSignedIn on success', () async {
      final auth = Fixtures.auth(uid: 'uid-1');
      authService.signInResult = Result.ok(auth);

      final result = await repository.signIn(
        email: 'test@example.com',
        password: 'secret',
      );

      expect(result, isA<Ok<dynamic>>());
      expect(result.asOk.value, same(auth));
      expect(repository.auth.value, same(auth));
      expect(repository.isSignedIn.value, isTrue);
      expect(
        authService.signInCalls.single,
        (email: 'test@example.com', password: 'secret'),
      );
    });

    test('keeps isSignedIn false and propagates the error on failure', () async {
      authService.signInResult = const Error(AuthUserEmailNotFound());

      final result = await repository.signIn(email: 'x@y.z', password: 'pw');

      expect(result, isA<Error<dynamic>>());
      expect(result.asError.error, isA<AuthUserEmailNotFound>());
      expect(repository.isSignedIn.value, isFalse);
      expect(repository.auth.value.uid, '');
    });

    test('a failed sign-in after a successful one clears isSignedIn', () async {
      await signInAs(Fixtures.auth(uid: 'uid-1'));
      authService.signInResult = const Error(AuthSignInFailed());

      await repository.signIn(email: 'x@y.z', password: 'pw');

      expect(repository.isSignedIn.value, isFalse);
      // The auth model itself is not cleared on a failed retry.
      expect(repository.auth.value.uid, 'uid-1');
    });
  });

  group('signInWithGoogle / signInWithApple', () {
    test('Google success publishes the auth', () async {
      final auth = Fixtures.auth(uid: 'g-1', email: 'g@gmail.com');
      authService.signInWithGoogleResult = Result.ok(auth);

      final result = await repository.signInWithGoogle();

      expect(result, isA<Ok<dynamic>>());
      expect(repository.auth.value, same(auth));
      expect(repository.isSignedIn.value, isTrue);
    });

    test('Google failure propagates and leaves the user signed out', () async {
      final result = await repository.signInWithGoogle();

      expect(result, isA<Error<dynamic>>());
      expect(result.asError.error, isA<AuthGoogleSignInFailed>());
      expect(repository.isSignedIn.value, isFalse);
    });

    test('Apple success publishes the auth', () async {
      final auth = Fixtures.auth(uid: 'a-1', email: 'a@icloud.com');
      authService.signInWithAppleResult = Result.ok(auth);

      final result = await repository.signInWithApple();

      expect(result, isA<Ok<dynamic>>());
      expect(repository.auth.value, same(auth));
      expect(repository.isSignedIn.value, isTrue);
    });

    test('Apple failure propagates and leaves the user signed out', () async {
      final result = await repository.signInWithApple();

      expect(result, isA<Error<dynamic>>());
      expect(result.asError.error, isA<AuthAppleSignInFailed>());
      expect(repository.isSignedIn.value, isFalse);
    });
  });

  group('requestSignUp', () {
    test('publishes the auth on success', () async {
      final auth = Fixtures.auth(uid: 'new', isEmailVerified: false);
      authService.signUpResult = Result.ok(auth);

      final result = await repository.requestSignUp(
        email: 'test@example.com',
        password: 'secret',
      );

      expect(result, isA<Ok<dynamic>>());
      expect(repository.auth.value, same(auth));
      expect(repository.isSignedIn.value, isTrue);
      expect(authService.signUpCalls.length, 1);
    });

    test('propagates the error without touching the notifiers', () async {
      authService.signUpResult = const Error(AuthUserAlreadyExists());

      final result = await repository.requestSignUp(
        email: 'test@example.com',
        password: 'secret',
      );

      expect(result, isA<Error<dynamic>>());
      expect(result.asError.error, isA<AuthUserAlreadyExists>());
      expect(repository.isSignedIn.value, isFalse);
    });
  });

  group('signOut', () {
    test('resets auth and isSignedIn on success', () async {
      await signInAs(Fixtures.auth(uid: 'uid-1'));

      final result = await repository.signOut();

      expect(result, isA<Ok<dynamic>>());
      expect(repository.auth.value.uid, '');
      expect(repository.isSignedIn.value, isFalse);
      expect(authService.signOutCount, 1);
    });

    test('keeps the session when the service fails', () async {
      await signInAs(Fixtures.auth(uid: 'uid-1'));
      final failure = Exception('Failed to sign out: x');
      authService.signOutResult = Result.error(failure);

      final result = await repository.signOut();

      expect(result, isA<Error<dynamic>>());
      expect(result.asError.error, same(failure));
      expect(repository.auth.value.uid, 'uid-1');
      expect(repository.isSignedIn.value, isTrue);
    });
  });

  group('deleteAccount', () {
    test('calls the cloud function and resets the session', () async {
      await signInAs(Fixtures.auth(uid: 'uid-1'));

      final result = await repository.deleteAccount();

      expect(result, isA<Ok<dynamic>>());
      expect(functionsService.deleteUserAccountCount, 1);
      // The auth service's own deleteAccount is not used.
      expect(authService.deleteAccountCount, 0);
      expect(repository.auth.value.uid, '');
      expect(repository.isSignedIn.value, isFalse);
    });

    test('keeps the session when the cloud function fails', () async {
      await signInAs(Fixtures.auth(uid: 'uid-1'));
      final failure = Exception('Failed to delete user account');
      functionsService.deleteUserAccountResult = Result.error(failure);

      final result = await repository.deleteAccount();

      expect(result, isA<Error<dynamic>>());
      expect(result.asError.error, same(failure));
      expect(repository.isSignedIn.value, isTrue);
    });
  });

  group('checkEmailVerification', () {
    test('updates isEmailVerified on the auth when signed in', () async {
      await signInAs(Fixtures.auth(uid: 'uid-1', isEmailVerified: false));
      authService.checkEmailVerificationResult = const Ok(true);

      final result = await repository.checkEmailVerification();

      expect(result, isA<Ok<bool>>());
      expect(result.asOk.value, isTrue);
      expect(repository.auth.value.isEmailVerified, isTrue);
      expect(repository.auth.value.uid, 'uid-1');
    });

    test('does not touch the auth model when nobody is signed in', () async {
      authService.checkEmailVerificationResult = const Ok(true);
      final before = repository.auth.value;

      final result = await repository.checkEmailVerification();

      expect(result.asOk.value, isTrue);
      expect(repository.auth.value, same(before));
    });

    test('propagates the error', () async {
      authService.checkEmailVerificationResult = const Error(
        AuthCheckEmailVerificationFailed(),
      );

      final result = await repository.checkEmailVerification();

      expect(result, isA<Error<bool>>());
      expect(result.asError.error, isA<AuthCheckEmailVerificationFailed>());
    });
  });

  group('pass-throughs', () {
    test('sendPasswordResetEmail forwards the email and result', () async {
      final result = await repository.sendPasswordResetEmail(
        email: 'test@example.com',
      );

      expect(result, isA<Ok<void>>());
      expect(authService.passwordResetEmails, ['test@example.com']);

      authService.sendPasswordResetEmailResult = const Error(
        AuthSendPasswordResetEmailFailed(),
      );
      expect(
        await repository.sendPasswordResetEmail(email: 'x'),
        isA<Error<void>>(),
      );
    });

    test('sendEmailVerification forwards the result', () async {
      expect(await repository.sendEmailVerification(), isA<Ok<void>>());

      authService.sendEmailVerificationResult = const Error(
        AuthEmailAlreadyVerified(),
      );
      final result = await repository.sendEmailVerification();
      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<AuthEmailAlreadyVerified>());
    });

    test('updatePassword forwards both passwords and the result', () async {
      final result = await repository.updatePassword(
        currentPassword: 'old',
        newPassword: 'new',
      );

      expect(result, isA<Ok<void>>());
      expect(
        authService.updatePasswordCalls.single,
        (currentPassword: 'old', newPassword: 'new'),
      );

      authService.updatePasswordResult = const Error(AuthChangePasswordFailed());
      expect(
        await repository.updatePassword(currentPassword: 'a', newPassword: 'b'),
        isA<Error<void>>(),
      );
    });
  });

  test('reauthenticate fails when Firebase reports no current user', () async {
    final result = await repository.reauthenticate();

    expect(result, isA<Error<dynamic>>());
    expect(
      result.asError.error.toString(),
      'Exception: No user is currently signed in',
    );
  });
}
