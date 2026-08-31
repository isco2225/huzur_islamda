import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAuthRepository authRepository;
  late SignInViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository();
    viewModel = SignInViewModel(authRepository: authRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('SignInViewModel.signIn', () {
    test('forwards the email/password record to the repository', () async {
      await viewModel.signIn.execute((
        email: 'user@example.com',
        password: 'secret123',
      ));

      expect(authRepository.calls, ['signIn(email=user@example.com)']);
      expect(viewModel.signIn.completed.value, isTrue);
      expect(viewModel.signIn.error.value, isFalse);
      expect(viewModel.signIn.result.value, isA<Ok<void>>());
    });

    test('propagates a repository error and flags the command', () async {
      const exception = AuthSignInFailed();
      authRepository.signInResult = const Error<dynamic>(exception);

      await viewModel.signIn.execute((email: 'a@b.c', password: 'x'));

      expect(viewModel.signIn.error.value, isTrue);
      expect(viewModel.signIn.completed.value, isFalse);
      final result = viewModel.signIn.result.value;
      expect(result, isA<Error<void>>());
      expect((result! as Error<void>).error, same(exception));
    });
  });

  group('SignInViewModel.signInWithGoogle', () {
    test('calls the repository and completes on Ok', () async {
      await viewModel.signInWithGoogle.execute();

      expect(authRepository.calls, ['signInWithGoogle()']);
      expect(viewModel.signInWithGoogle.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      const exception = AuthGoogleSignInFailed();
      authRepository.signInWithGoogleResult = const Error<dynamic>(exception);

      await viewModel.signInWithGoogle.execute();

      expect(viewModel.signInWithGoogle.error.value, isTrue);
      expect(
        (viewModel.signInWithGoogle.result.value! as Error<void>).error,
        same(exception),
      );
    });
  });

  group('SignInViewModel.signInWithApple', () {
    test('calls the repository and completes on Ok', () async {
      await viewModel.signInWithApple.execute();

      expect(authRepository.calls, ['signInWithApple()']);
      expect(viewModel.signInWithApple.completed.value, isTrue);
    });

    test('propagates a repository error', () async {
      const exception = AuthAppleSignInFailed();
      authRepository.signInWithAppleResult = const Error<dynamic>(exception);

      await viewModel.signInWithApple.execute();

      expect(viewModel.signInWithApple.error.value, isTrue);
      expect(
        (viewModel.signInWithApple.result.value! as Error<void>).error,
        same(exception),
      );
    });
  });

  group('SignInViewModel.isAnySignInRunning', () {
    test('is false when no command is running', () {
      expect(viewModel.isAnySignInRunning.value, isFalse);
    });

    test('is true while Google sign-in is in flight and resets after', () async {
      final gate = Completer<Result<dynamic>>();
      authRepository.onSignInWithGoogle = () => gate.future;
      final seen = <bool>[];
      viewModel.isAnySignInRunning.addListener(
        () => seen.add(viewModel.isAnySignInRunning.value),
      );

      final execution = viewModel.signInWithGoogle.execute();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.signInWithGoogle.running.value, isTrue);
      expect(viewModel.isAnySignInRunning.value, isTrue);

      gate.complete(const Ok(null));
      await execution;

      expect(viewModel.isAnySignInRunning.value, isFalse);
      expect(seen, [true, false]);
    });

    test('stops notifying after dispose', () async {
      final gate = Completer<Result<dynamic>>();
      authRepository.onSignInWithGoogle = () => gate.future;
      final execution = viewModel.signInWithGoogle.execute();
      await Future<void>.delayed(Duration.zero);
      expect(viewModel.isAnySignInRunning.value, isTrue);

      viewModel.dispose();
      gate.complete(const Ok(null));
      await execution;

      // Re-create so the shared tearDown has something to dispose.
      viewModel = SignInViewModel(authRepository: authRepository);
    });
  });
}
