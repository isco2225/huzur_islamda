import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  group('CreateUserProfileUseCase', () {
    late FakeUserRepository userRepository;
    late FakeAuthRepository authRepository;
    late CreateUserProfileUseCase useCase;

    setUp(() {
      userRepository = FakeUserRepository();
      authRepository = FakeAuthRepository(
        auth: Fixtures.auth(uid: 'uid-42', email: 'me@x.io'),
      );
      useCase = CreateUserProfileUseCase(
        userRepository: userRepository,
        authRepository: authRepository,
      );
    });

    test('creates the user with uid and email taken from auth', () async {
      final result = await useCase.execute(
        name: 'Ahmet',
        surname: 'Yılmaz',
        dateOfBirth: '01/01/1990',
        gender: 'male',
      );

      expect(result, isA<Ok<void>>());
      expect(userRepository.calls, [
        'createUser(uid=uid-42, email=me@x.io, name=Ahmet, surname=Yılmaz, '
            'dateOfBirth=01/01/1990, gender=male)',
      ]);
    });

    test('propagates the repository error', () async {
      final exception = Exception('firestore down');
      userRepository.createUserResult = Error(exception);

      final result = await useCase.execute(
        name: 'Ahmet',
        surname: 'Yılmaz',
        dateOfBirth: '01/01/1990',
        gender: 'male',
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('wraps a thrown exception into an Error result', () async {
      userRepository.onCreateUser =
          ({
            required uid,
            required email,
            required name,
            required surname,
            required dateOfBirth,
            required gender,
          }) async => throw StateError('boom');

      final result = await useCase.execute(
        name: 'Ahmet',
        surname: 'Yılmaz',
        dateOfBirth: '01/01/1990',
        gender: 'male',
      );

      expect(result, isA<Error<void>>());
      expect(result.asError.error.toString(), contains('boom'));
    });

    test('still calls the repository when auth is empty', () async {
      authRepository.authNotifier.value = Auth.empty();

      await useCase.execute(
        name: 'Ahmet',
        surname: 'Yılmaz',
        dateOfBirth: '01/01/1990',
        gender: 'male',
      );

      expect(userRepository.calls.single, startsWith('createUser(uid=, email=,'));
    });
  });

  group('DeleteAccountUseCase', () {
    late FakeAuthRepository authRepository;
    late DeleteAccountUseCase useCase;

    setUp(() {
      authRepository = FakeAuthRepository(auth: Fixtures.auth());
      useCase = DeleteAccountUseCase(authRepository: authRepository);
    });

    test('deletes the account and then signs out on success', () async {
      final result = await useCase.execute();

      expect(result, isA<Ok<void>>());
      expect(authRepository.calls, ['deleteAccount()', 'signOut()']);
    });

    test('does not sign out when deleting the account fails', () async {
      authRepository.deleteAccountResult = const Error(
        AuthDeleteAccountFailed(),
      );

      final result = await useCase.execute();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, isA<AuthDeleteAccountFailed>());
      expect(authRepository.calls, ['deleteAccount()']);
    });

    test('ignores a failed sign out after a successful delete', () async {
      authRepository.signOutResult = Error(Exception('sign out failed'));

      final result = await useCase.execute();

      expect(result, isA<Ok<void>>());
      expect(authRepository.calls, ['deleteAccount()', 'signOut()']);
    });
  });

  group('WipeDataUseCase', () {
    late FakeDhikrRepository dhikrRepository;
    late FakePrayerRepository prayerRepository;
    late FakeUserRepository userRepository;
    late FakeNotificationRepository notificationRepository;
    late WipeDataUseCase useCase;

    setUp(() {
      dhikrRepository = FakeDhikrRepository();
      prayerRepository = FakePrayerRepository();
      userRepository = FakeUserRepository(currentUser: Fixtures.user());
      notificationRepository = FakeNotificationRepository();
      useCase = WipeDataUseCase(
        dhikrRepository: dhikrRepository,
        prayerRepository: prayerRepository,
        userRepository: userRepository,
        notificationRepository: notificationRepository,
      );
    });

    /// Each repository is touched exactly once and in a fixed order, so the
    /// concatenation of the per-fake logs reflects the execution order.
    List<String> combinedCalls() => [
      ...dhikrRepository.calls,
      ...prayerRepository.calls,
      ...notificationRepository.calls,
      ...userRepository.calls,
    ];

    test('clears dhikrs, prayers, notifications then wipes the user', () async {
      final result = await useCase.wipeData();

      expect(result, isA<Ok<void>>());
      expect(combinedCalls(), [
        'clearAllDhikrsLocally()',
        'clearAllPrayerTimesLocally()',
        'cancelAllNotifications()',
        'wipeUser()',
      ]);
      expect(userRepository.currentUserNotifier.value.uid, isEmpty);
    });

    test('stops at the dhikr step when it fails', () async {
      final exception = Exception('hive');
      dhikrRepository.clearAllDhikrsLocallyResult = Error(exception);

      final result = await useCase.wipeData();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
      expect(prayerRepository.calls, isEmpty);
      expect(notificationRepository.calls, isEmpty);
      expect(userRepository.calls, isEmpty);
    });

    test('stops at the prayer step when it fails', () async {
      prayerRepository.clearAllPrayerTimesLocallyResult = Error(
        Exception('prayer'),
      );

      final result = await useCase.wipeData();

      expect(result, isA<Error<void>>());
      expect(dhikrRepository.calls, ['clearAllDhikrsLocally()']);
      expect(notificationRepository.calls, isEmpty);
      expect(userRepository.calls, isEmpty);
    });

    test('stops at the notification step when it fails', () async {
      notificationRepository.cancelAllNotificationsResult = Error(
        Exception('notif'),
      );

      final result = await useCase.wipeData();

      expect(result, isA<Error<void>>());
      expect(userRepository.calls, isEmpty);
    });
  });
}
