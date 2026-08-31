import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  late FakeAuthRepository authRepository;
  late ResetPasswordViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository();
    viewModel = ResetPasswordViewModel(authRepository: authRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ResetPasswordViewModel.sendResetEmail', () {
    test('forwards the email and completes on Ok', () async {
      await viewModel.sendResetEmail.execute('forgot@example.com');

      expect(authRepository.calls, [
        'sendPasswordResetEmail(email=forgot@example.com)',
      ]);
      expect(viewModel.sendResetEmail.completed.value, isTrue);
      expect(viewModel.sendResetEmail.result.value, isA<Ok<void>>());
    });

    test('propagates a repository error', () async {
      final exception = Exception('no such user');
      authRepository.sendPasswordResetEmailResult = Error<void>(exception);

      await viewModel.sendResetEmail.execute('forgot@example.com');

      expect(viewModel.sendResetEmail.error.value, isTrue);
      final result = viewModel.sendResetEmail.result.value;
      expect(result, isA<Error<void>>());
      expect(result!.asError.error, same(exception));
    });
  });
}
