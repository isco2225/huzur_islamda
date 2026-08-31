import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAuthRepository authRepository;
  late ChangePasswordViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    viewModel = ChangePasswordViewModel(authRepository: authRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ChangePasswordViewModel.changePassword', () {
    test('calls updatePassword and completes on Ok', () async {
      await viewModel.changePassword.execute((
        currentPassword: 'old-pass',
        newPassword: 'new-pass',
      ));

      expect(authRepository.calls, ['updatePassword()']);
      expect(viewModel.changePassword.completed.value, isTrue);
      expect(viewModel.changePassword.result.value, isA<Ok<void>>());
    });

    test('propagates a repository error', () async {
      const exception = AuthChangePasswordFailed();
      authRepository.updatePasswordResult = const Error<void>(exception);

      await viewModel.changePassword.execute((
        currentPassword: 'wrong',
        newPassword: 'new-pass',
      ));

      expect(viewModel.changePassword.error.value, isTrue);
      final result = viewModel.changePassword.result.value;
      expect(result, isA<Error<void>>());
      expect(result!.asError.error, same(exception));
    });
  });
}
