import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../../../helpers/helpers.dart';

void main() {
  late FakeUserRepository userRepository;
  late FakeAuthRepository authRepository;
  late CreateUserProfileViewModel viewModel;

  setUp(() {
    userRepository = FakeUserRepository();
    authRepository = FakeAuthRepository(
      auth: Fixtures.auth(uid: 'auth-uid', email: 'auth@example.com'),
    );
    viewModel = CreateUserProfileViewModel(
      createUserProfileUseCase: CreateUserProfileUseCase(
        userRepository: userRepository,
        authRepository: authRepository,
      ),
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('createUserProfile (real CreateUserProfileUseCase)', () {
    test(
      'forwards name/surname/dob/gender together with the auth uid and email',
      () async {
        await viewModel.createUserProfile.execute((
          name: 'Ayşe',
          surname: 'Demir',
          dateOfBirth: '02/03/1995',
          gender: 'female',
        ));

        expect(userRepository.calls, [
          'createUser(uid=auth-uid, email=auth@example.com, name=Ayşe, '
              'surname=Demir, dateOfBirth=02/03/1995, gender=female)',
        ]);
        expect(viewModel.createUserProfile.completed.value, isTrue);
        expect(viewModel.createUserProfile.result.value, isA<Ok<void>>());
      },
    );

    test('propagates a repository error', () async {
      final exception = Exception('firestore write failed');
      userRepository.createUserResult = Error<User>(exception);

      await viewModel.createUserProfile.execute((
        name: 'A',
        surname: 'B',
        dateOfBirth: '01/01/2000',
        gender: 'male',
      ));

      expect(viewModel.createUserProfile.error.value, isTrue);
      expect(
        viewModel.createUserProfile.result.value!.asError.error,
        same(exception),
      );
    });
  });
}
