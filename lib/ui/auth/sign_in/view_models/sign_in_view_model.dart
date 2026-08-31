import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';

class SignInViewModel {
  SignInViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    // DEFINE COMMANDS
    signIn = Command1(_signIn, debugLabel: 'signIn');
    signInWithGoogle = Command0(
      _signInWithGoogle,
      debugLabel: 'signInWithGoogle',
    );
    signInWithApple = Command0(
      _signInWithApple,
      debugLabel: 'signInWithApple',
    );
    // DEFINE LISTENERS
    _isAnySignInRunning = _AnyRunning([
      signIn.running,
      signInWithGoogle.running,
      signInWithApple.running,
    ]);
  }

  // LOGGER
  final _log = Logger('SignInViewModel');

  // REPOSITORIES & USE CASES
  final AuthRepository _authRepository;

  // DOMAIN

  // COMMANDS
  late Command1<void, ({String email, String password})> signIn;
  late Command0<void> signInWithGoogle;
  late Command0<void> signInWithApple;

  // LISTENABLES
  late final _AnyRunning _isAnySignInRunning;

  /// True while any sign-in method (email, Google or Apple) is in flight.
  /// Used by the view to disable the other sign-in buttons meanwhile.
  ValueListenable<bool> get isAnySignInRunning => _isAnySignInRunning;

  // DISPOSE
  void dispose() {
    _isAnySignInRunning.dispose();
    signIn.dispose();
    signInWithGoogle.dispose();
    signInWithApple.dispose();
  }

  // FUNCTIONS
  Future<Result<void>> _signIn(
    ({String email, String password}) commands,
  ) async {
    // Sign in with Firebase Auth
    final signInResult = await _authRepository.signIn(
      email: commands.email,
      password: commands.password,
    );

    switch (signInResult) {
      case Ok():
        _log.info('Sign in successful');
        return Result.ok(null);
      case Error():
        _log.warning('Sign in failed: ${signInResult.asError.error}');
        return Result.error(signInResult.asError.error);
    }
  }

  Future<Result<void>> _signInWithGoogle() async {
    _log.info('Signing in with Google...');
    final signInWithGoogleResult = await _authRepository.signInWithGoogle();
    switch (signInWithGoogleResult) {
      case Ok():
        _log.info('Sign in with Google successful');
        return Result.ok(null);
      case Error():
        _log.warning(
          'Sign in with Google failed: ${signInWithGoogleResult.asError.error}',
        );
        return Result.error(signInWithGoogleResult.asError.error);
    }
  }

  Future<Result<void>> _signInWithApple() async {
    _log.info('Signing in with Apple...');
    final signInWithAppleResult = await _authRepository.signInWithApple();
    switch (signInWithAppleResult) {
      case Ok():
        _log.info('Sign in with Apple successful');
        return Result.ok(null);
      case Error():
        _log.warning(
          'Sign in with Apple failed: ${signInWithAppleResult.asError.error}',
        );
        return Result.error(signInWithAppleResult.asError.error);
    }
  }
}

/// OR-combines several boolean listenables into one.
class _AnyRunning extends ValueNotifier<bool> {
  _AnyRunning(this._sources) : super(_sources.any((s) => s.value)) {
    for (final source in _sources) {
      source.addListener(_recompute);
    }
  }

  final List<ValueListenable<bool>> _sources;

  void _recompute() => value = _sources.any((s) => s.value);

  @override
  void dispose() {
    for (final source in _sources) {
      source.removeListener(_recompute);
    }
    super.dispose();
  }
}
