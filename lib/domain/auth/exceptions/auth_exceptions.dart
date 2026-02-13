sealed class AuthException implements Exception {
  const AuthException();
}

final class AuthSignUpFailed extends AuthException {
  const AuthSignUpFailed();
}

final class AuthUserAlreadyExists extends AuthException {
  const AuthUserAlreadyExists();
}

final class AuthSignInFailed extends AuthException {
  const AuthSignInFailed();
}

final class AuthEmailUsedWithDifferentProvider extends AuthException {
  const AuthEmailUsedWithDifferentProvider();
}

final class AuthGoogleSignInFailed extends AuthException {
  const AuthGoogleSignInFailed();
}

final class AuthNoUserSignedIn extends AuthException {
  const AuthNoUserSignedIn();
}

final class AuthUserEmailNotFound extends AuthException {
  const AuthUserEmailNotFound();
}

final class AuthSendVerificationEmailFailed extends AuthException {
  const AuthSendVerificationEmailFailed();
}

final class AuthEmailAlreadyVerified extends AuthException {
  const AuthEmailAlreadyVerified();
}

final class AuthCheckEmailVerificationFailed extends AuthException {
  const AuthCheckEmailVerificationFailed();
}

final class AuthDeleteAccountFailed extends AuthException {
  const AuthDeleteAccountFailed();
}

final class AuthSendPasswordResetEmailFailed extends AuthException {
  const AuthSendPasswordResetEmailFailed();
}

final class AuthChangePasswordFailed extends AuthException {
  const AuthChangePasswordFailed();
}
