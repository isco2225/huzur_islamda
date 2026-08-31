import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late FakeAuthRepository authRepository;
  late SignUpViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    viewModel = SignUpViewModel(authRepository: authRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('auth mirrors the repository listenable', () {
    expect(viewModel.auth, same(authRepository.authNotifier));
    expect(viewModel.auth.value.uid, 'uid-1');
  });

  group('SignUpViewModel.requestSignUp', () {
    test('forwards the email/password record and completes on Ok', () async {
      await viewModel.requestSignUp.execute((
        email: 'new@example.com',
        password: 'pass1234',
      ));

      expect(authRepository.calls, ['requestSignUp(email=new@example.com)']);
      expect(viewModel.requestSignUp.completed.value, isTrue);
      expect(viewModel.requestSignUp.result.value, isA<Ok<void>>());
    });

    test('propagates a repository error', () async {
      const exception = AuthSignUpFailed();
      authRepository.requestSignUpResult = const Error<dynamic>(exception);

      await viewModel.requestSignUp.execute((email: 'a@b.c', password: 'x'));

      expect(viewModel.requestSignUp.error.value, isTrue);
      final result = viewModel.requestSignUp.result.value;
      expect(result, isA<Error<void>>());
      expect(result!.asError.error, same(exception));
    });
  });
}
