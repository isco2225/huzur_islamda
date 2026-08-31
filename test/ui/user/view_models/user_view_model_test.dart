import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late FakeAuthRepository authRepository;
  late FakeUserRepository userRepository;
  late UserViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository(auth: Fixtures.auth(), isSignedIn: true);
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    viewModel = UserViewModel(
      deleteAccountUseCase: DeleteAccountUseCase(authRepository: authRepository),
      userRepository: userRepository,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('user mirrors the repository listenable', () {
    expect(viewModel.user, same(userRepository.currentUserNotifier));
    expect(viewModel.user.value.uid, 'uid-1');
  });

  group('deleteAccount (real DeleteAccountUseCase)', () {
    test('deletes the account then signs out on success', () async {
      await viewModel.deleteAccount.execute();

      expect(authRepository.calls, ['deleteAccount()', 'signOut()']);
      expect(viewModel.deleteAccount.completed.value, isTrue);
      expect(viewModel.deleteAccount.result.value, isA<Ok<void>>());
    });

    test('does not sign out and propagates the error on failure', () async {
      const exception = AuthDeleteAccountFailed();
      authRepository.deleteAccountResult = const Error<dynamic>(exception);

      await viewModel.deleteAccount.execute();

      expect(authRepository.calls, ['deleteAccount()']);
      expect(viewModel.deleteAccount.error.value, isTrue);
      expect(
        viewModel.deleteAccount.result.value!.asError.error,
        same(exception),
      );
    });
  });
}
