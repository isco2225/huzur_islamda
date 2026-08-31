import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

/// Note on `_fetchCurrentUser`: the repository returns `Result<bool>`, so the
/// `if (result is Error<User>)` branch can never match and is dead code. The
/// result object is still returned unchanged, so an `Error<bool>` does reach
/// the command and `error.value` flips to true. Only the warning log is lost.
void main() {
  late FakeUserRepository userRepository;
  late FakeAuthRepository authRepository;
  late FetchUserViewModel viewModel;

  setUp(() {
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    authRepository = FakeAuthRepository(auth: Fixtures.auth(uid: 'auth-uid'));
    viewModel = FetchUserViewModel(
      userRepository: userRepository,
      authRepository: authRepository,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('currentUser and auth mirror the repository listenables', () {
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
    expect(viewModel.auth, same(authRepository.authNotifier));
  });

  group('fetchCurrentUser', () {
    test('calls fetchAuthenticatedUser with the auth uid', () async {
      await viewModel.fetchCurrentUser.execute();

      expect(userRepository.calls, ['fetchAuthenticatedUser(uid=auth-uid)']);
      expect(viewModel.fetchCurrentUser.completed.value, isTrue);
      expect(viewModel.fetchCurrentUser.result.value, isA<Ok<dynamic>>());
    });

    test('uses the current auth uid at execution time', () async {
      authRepository.authNotifier.value = Fixtures.auth(uid: 'later-uid');

      await viewModel.fetchCurrentUser.execute();

      expect(userRepository.calls, ['fetchAuthenticatedUser(uid=later-uid)']);
    });

    test(
      'a repository Error still surfaces as command error despite the dead '
      '`is Error<User>` branch',
      () async {
        final exception = Exception('firestore');
        userRepository.fetchAuthenticatedUserResult = Error<bool>(exception);

        await viewModel.fetchCurrentUser.execute();

        expect(viewModel.fetchCurrentUser.error.value, isTrue);
        expect(viewModel.fetchCurrentUser.completed.value, isFalse);
        expect(
          viewModel.fetchCurrentUser.result.value!.asError.error,
          same(exception),
        );
      },
    );
  });
}
