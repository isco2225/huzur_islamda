import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late FakeAuthRepository authRepository;
  late AuthViewModel viewModel;

  setUp(() {
    authRepository = FakeAuthRepository(auth: Fixtures.auth());
    viewModel = AuthViewModel(authRepository: authRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('auth is the repository listenable and follows its updates', () {
    expect(viewModel.auth, same(authRepository.authNotifier));
    expect(viewModel.auth.value.uid, 'uid-1');

    authRepository.authNotifier.value = Auth.empty();

    expect(viewModel.auth.value.uid, isEmpty);
    expect(viewModel.auth.value.isSignedIn(), isFalse);
  });

  test('dispose does not throw', () {
    expect(viewModel.dispose, returnsNormally);
  });
}
