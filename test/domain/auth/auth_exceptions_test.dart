import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';

void main() {
  group('AuthException subclasses', () {
    const all = <AuthException>[
      AuthSignUpFailed(),
      AuthUserAlreadyExists(),
      AuthSignInFailed(),
      AuthEmailUsedWithDifferentProvider(),
      AuthGoogleSignInFailed(),
      AuthAppleSignInFailed(),
      AuthNoUserSignedIn(),
      AuthUserEmailNotFound(),
      AuthSendVerificationEmailFailed(),
      AuthEmailAlreadyVerified(),
      AuthCheckEmailVerificationFailed(),
      AuthDeleteAccountFailed(),
      AuthSendPasswordResetEmailFailed(),
      AuthChangePasswordFailed(),
    ];

    test('every subclass implements Exception', () {
      for (final exception in all) {
        expect(exception, isA<Exception>(), reason: '$exception');
      }
    });

    test('every subclass can be constructed as a const', () {
      // Const instances of the same class are canonicalized.
      expect(identical(const AuthSignUpFailed(), const AuthSignUpFailed()), isTrue);
      expect(
        identical(const AuthNoUserSignedIn(), const AuthNoUserSignedIn()),
        isTrue,
      );
      expect(all.length, 14);
    });

    test('subclasses are distinguishable by type', () {
      expect(const AuthSignInFailed(), isNot(isA<AuthSignUpFailed>()));
      expect(const AuthSignInFailed(), isA<AuthSignInFailed>());
    });

    test('AuthProviderType exposes the three supported providers', () {
      expect(AuthProviderType.values, [
        AuthProviderType.emailPassword,
        AuthProviderType.google,
        AuthProviderType.apple,
      ]);
    });
  });
}
