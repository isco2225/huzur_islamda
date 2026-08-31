import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../helpers/helpers.dart';

/// [LogOutViewModel._logOut] hard-codes a 3 second `Future.delayed` before
/// calling the repository, so the two flow tests below really wait ~3s each.
/// They carry an explicit timeout to make that intent visible.
void main() {
  late FakeAuthRepository authRepository;
  late LogOutViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository(isSignedIn: true);
    viewModel = LogOutViewModel(authRepository: authRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('command is idle before execution', () {
    expect(viewModel.logOut.running.value, isFalse);
    expect(viewModel.logOut.result.value, isNull);
  });

  test('does not call signOut before the 3 second delay elapses', () async {
    final future = viewModel.logOut.execute();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(viewModel.logOut.running.value, isTrue);
    expect(authRepository.calls, isEmpty);

    await future;
  }, timeout: const Timeout(Duration(seconds: 10)));

  test(
    'calls signOut after the delay and completes on Ok',
    () async {
      await viewModel.logOut.execute();

      expect(authRepository.calls, ['signOut()']);
      expect(viewModel.logOut.completed.value, isTrue);
      expect(viewModel.logOut.result.value, isA<Ok<void>>());
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );

  test(
    'propagates a signOut error',
    () async {
      final exception = Exception('network');
      authRepository.signOutResult = Error<dynamic>(exception);

      await viewModel.logOut.execute();

      expect(viewModel.logOut.error.value, isTrue);
      expect(viewModel.logOut.result.value!.asError.error, same(exception));
    },
    timeout: const Timeout(Duration(seconds: 10)),
  );
}
