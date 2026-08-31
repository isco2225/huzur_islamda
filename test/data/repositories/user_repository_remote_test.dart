import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/errors/models/user_message_exception.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeFirestoreUserService firestore;
  late UserRepositoryRemote repository;

  setUp(() {
    firestore = FakeFirestoreUserService();
    repository = UserRepositoryRemote(firestoreUserService: firestore);
  });

  test('starts with an empty user', () {
    final user = repository.currentUser.value;

    expect(user.uid, '');
    expect(user.isRegistered, isFalse);
    expect(user.isPremium, isFalse);
  });

  group('createUser', () {
    Future<Result<User>> create({
      String name = 'Ahmet',
      String surname = 'Yılmaz',
      String gender = 'male',
    }) {
      return repository.createUser(
        uid: 'uid-1',
        email: 'a@b.com',
        name: name,
        surname: surname,
        dateOfBirth: '01/01/1990',
        gender: gender,
      );
    }

    test('rejects an empty name without calling the service', () async {
      final result = await create(name: '');

      expect(result, isA<Error<User>>());
      expect(result.asError.error, isA<UserMessageException>());
      expect(
        (result.asError.error as UserMessageException).message,
        'Ad, soyad ve cinsiyet zorunludur',
      );
      expect(firestore.createUserCalls, isEmpty);
      expect(repository.currentUser.value.uid, '');
    });

    test('rejects an empty surname without calling the service', () async {
      final result = await create(surname: '');

      expect(result, isA<Error<User>>());
      expect(firestore.createUserCalls, isEmpty);
    });

    test('rejects an empty gender without calling the service', () async {
      final result = await create(gender: '');

      expect(result, isA<Error<User>>());
      expect(firestore.createUserCalls, isEmpty);
    });

    test('forwards the fields and publishes the created user', () async {
      final created = Fixtures.user(uid: 'uid-1', name: 'Ahmet');
      firestore.createUserResult = Result.ok(created);

      final result = await create();

      expect(result, isA<Ok<User>>());
      expect(result.asOk.value, same(created));
      expect(repository.currentUser.value, same(created));
      expect(firestore.createUserCalls.single, {
        'uid': 'uid-1',
        'email': 'a@b.com',
        'name': 'Ahmet',
        'surname': 'Yılmaz',
        'dateOfBirth': '01/01/1990',
        'gender': 'male',
      });
    });

    test('propagates a service error and keeps the notifier', () async {
      final failure = Exception('Failed to create user: offline');
      firestore.createUserResult = Result.error(failure);

      final result = await create();

      expect(result, isA<Error<User>>());
      expect(result.asError.error, same(failure));
      expect(repository.currentUser.value.uid, '');
    });
  });

  group('initUser', () {
    test(
      'publishes a placeholder user with the uid and isRegistered=false, '
      'returning Ok(false), when Firestore has no document',
      () async {
        firestore.readAuthenticatedUserResult = const Ok(null);

        final result = await repository.initUser(uid: 'uid-9');

        expect(result, isA<Ok<bool>>());
        expect(result.asOk.value, isFalse);
        final user = repository.currentUser.value;
        expect(user.uid, 'uid-9');
        expect(user.email, '');
        expect(user.isRegistered, isFalse);
        expect(user.country, isNull);
        expect(user.city, isNull);
        expect(user.districtId, isNull);
        expect(user.createdAt, isNull);
        expect(firestore.readAuthenticatedUserUids, ['uid-9']);
      },
    );

    test('publishes the Firestore user and returns Ok(true)', () async {
      final stored = Fixtures.user(uid: 'uid-9');
      firestore.readAuthenticatedUserResult = Result.ok(stored);

      final result = await repository.initUser(uid: 'uid-9');

      expect(result.asOk.value, isTrue);
      expect(repository.currentUser.value, same(stored));
    });

    test('propagates a service error', () async {
      final failure = Exception('Failed to get user: x');
      firestore.readAuthenticatedUserResult = Result.error(failure);

      final result = await repository.initUser(uid: 'uid-9');

      expect(result, isA<Error<bool>>());
      expect(result.asError.error, same(failure));
      expect(repository.currentUser.value.uid, '');
    });
  });

  group('fetchAuthenticatedUser', () {
    test(
      'resets the notifier to User.empty() (uid cleared) and returns Ok(false) '
      'when Firestore has no document - unlike initUser, which keeps the uid',
      () async {
        firestore.readAuthenticatedUserResult = Result.ok(
          Fixtures.user(uid: 'uid-9'),
        );
        await repository.initUser(uid: 'uid-9');
        firestore.readAuthenticatedUserResult = const Ok(null);

        final result = await repository.fetchAuthenticatedUser(uid: 'uid-9');

        expect(result.asOk.value, isFalse);
        final user = repository.currentUser.value;
        expect(user.uid, '');
        expect(user.isRegistered, isFalse);
        // User.empty() uses '' for location fields whereas initUser uses null.
        expect(user.country, '');
      },
    );

    test('publishes the Firestore user and returns Ok(true)', () async {
      final stored = Fixtures.user(uid: 'uid-9');
      firestore.readAuthenticatedUserResult = Result.ok(stored);

      final result = await repository.fetchAuthenticatedUser(uid: 'uid-9');

      expect(result.asOk.value, isTrue);
      expect(repository.currentUser.value, same(stored));
    });

    test('propagates a service error', () async {
      firestore.readAuthenticatedUserResult = Result.error(Exception('x'));

      expect(
        await repository.fetchAuthenticatedUser(uid: 'uid-9'),
        isA<Error<bool>>(),
      );
    });
  });

  group('updateUser', () {
    setUp(() async {
      firestore.readAuthenticatedUserResult = Result.ok(
        Fixtures.user(uid: 'uid-1', name: 'Ahmet', surname: 'Yılmaz'),
      );
      await repository.initUser(uid: 'uid-1');
    });

    test('patches only the provided fields on the notifier', () async {
      final result = await repository.updateUser(
        uid: 'uid-1',
        name: 'Mehmet',
        dateOfBirth: '02/02/1992',
      );

      expect(result, isA<Ok<void>>());
      final user = repository.currentUser.value;
      expect(user.name, 'Mehmet');
      expect(user.surname, 'Yılmaz');
      expect(user.dateOfBirth, '02/02/1992');
      expect(user.gender, 'male');
      expect(firestore.updateUserCalls.single, {
        'uid': 'uid-1',
        'name': 'Mehmet',
        'surname': null,
        'dateOfBirth': '02/02/1992',
        'gender': null,
      });
    });

    test('keeps the notifier when the service fails', () async {
      firestore.updateUserResult = Result.error(Exception('x'));

      final result = await repository.updateUser(uid: 'uid-1', name: 'Mehmet');

      expect(result, isA<Error<void>>());
      expect(repository.currentUser.value.name, 'Ahmet');
    });
  });

  group('updateEmailVerificationStatus', () {
    test('forwards the flag and patches the notifier', () async {
      firestore.readAuthenticatedUserResult = Result.ok(
        Fixtures.user(emailVerified: false),
      );
      await repository.initUser(uid: 'uid-1');

      final result = await repository.updateEmailVerificationStatus(
        uid: 'uid-1',
        emailVerified: true,
      );

      expect(result, isA<Ok<void>>());
      expect(repository.currentUser.value.emailVerified, isTrue);
      expect(
        firestore.updateEmailVerificationStatusCalls.single,
        (uid: 'uid-1', emailVerified: true),
      );
    });

    test('keeps the notifier when the service fails', () async {
      firestore.updateEmailVerificationStatusResult = Result.error(
        Exception('x'),
      );

      final result = await repository.updateEmailVerificationStatus(
        uid: 'uid-1',
        emailVerified: true,
      );

      expect(result, isA<Error<void>>());
      expect(repository.currentUser.value.emailVerified, isFalse);
    });
  });

  group('deleteAuthenticatedUser', () {
    test('resets the notifier to an empty user', () async {
      firestore.readAuthenticatedUserResult = Result.ok(Fixtures.user());
      await repository.initUser(uid: 'uid-1');

      final result = await repository.deleteAuthenticatedUser(uid: 'uid-1');

      expect(result, isA<Ok<void>>());
      expect(repository.currentUser.value.uid, '');
      expect(firestore.deleteAuthenticatedUserUids, ['uid-1']);
    });

    test('keeps the notifier when the service fails', () async {
      firestore.readAuthenticatedUserResult = Result.ok(Fixtures.user());
      await repository.initUser(uid: 'uid-1');
      firestore.deleteAuthenticatedUserResult = Result.error(Exception('x'));

      final result = await repository.deleteAuthenticatedUser(uid: 'uid-1');

      expect(result, isA<Error<void>>());
      expect(repository.currentUser.value.uid, 'uid-1');
    });
  });

  test('wipeUser resets the notifier synchronously', () async {
    firestore.readAuthenticatedUserResult = Result.ok(Fixtures.user());
    await repository.initUser(uid: 'uid-1');

    repository.wipeUser();

    expect(repository.currentUser.value.uid, '');
    expect(repository.currentUser.value.isRegistered, isFalse);
  });

  group('updateUserLocation', () {
    test('patches the notifier when Firestore returns the user', () async {
      firestore.readAuthenticatedUserResult = Result.ok(Fixtures.user());
      await repository.initUser(uid: 'uid-1');
      firestore.updateUserLocationResult = Result.ok(Fixtures.user());

      final result = await repository.updateUserLocation(
        uid: 'uid-1',
        country: 'Türkiye',
        city: 'Ankara',
        districtId: '9206',
      );

      expect(result, isA<Ok<void>>());
      final user = repository.currentUser.value;
      expect(user.city, 'Ankara');
      expect(user.districtId, '9206');
      expect(firestore.updateUserLocationCalls.single['city'], 'Ankara');
    });

    test('returns Error and keeps the notifier when Firestore returns null', () async {
      firestore.readAuthenticatedUserResult = Result.ok(Fixtures.user());
      await repository.initUser(uid: 'uid-1');
      firestore.updateUserLocationResult = const Ok(null);

      final result = await repository.updateUserLocation(
        uid: 'uid-1',
        country: 'Türkiye',
        city: 'Ankara',
        districtId: '9206',
      );

      expect(result, isA<Error<void>>());
      expect(
        result.asError.error.toString(),
        'Exception: User not found on firestore',
      );
      expect(repository.currentUser.value.city, 'İstanbul');
    });
  });

  group('updateUserPremium', () {
    test('publishes the user returned by Firestore', () async {
      final premiumUser = Fixtures.user(
        supportPackage: SupportPackage.yearly,
        lastSupportedAt: DateTime(2026, 5, 1),
      );
      firestore.updateUserSupportResult = Result.ok(premiumUser);
      final when = DateTime(2026, 5, 1);

      final result = await repository.updateUserPremium(
        uid: 'uid-1',
        lastPremiumAt: when,
        supportPackage: SupportPackage.yearly,
      );

      expect(result, isA<Ok<void>>());
      expect(repository.currentUser.value, same(premiumUser));
      expect(repository.currentUser.value.isPremium, isTrue);
      expect(firestore.updateUserSupportCalls.single, {
        'uid': 'uid-1',
        'hasSupported': true,
        'lastSupportedAt': when,
        'supportPackage': 'yearly',
      });
    });

    test('falls back to patching the notifier when Firestore returns null', () async {
      firestore.readAuthenticatedUserResult = Result.ok(Fixtures.user());
      await repository.initUser(uid: 'uid-1');
      firestore.updateUserSupportResult = const Ok(null);
      final when = DateTime(2026, 5, 1);

      final result = await repository.updateUserPremium(
        uid: 'uid-1',
        lastPremiumAt: when,
        supportPackage: SupportPackage.weekly,
      );

      expect(result, isA<Ok<void>>());
      final user = repository.currentUser.value;
      expect(user.uid, 'uid-1');
      expect(user.supportPackage, SupportPackage.weekly);
      expect(user.lastSupportedAt, when);
      expect(user.isPremium, isTrue);
    });

    test('propagates a service error and keeps the notifier', () async {
      firestore.updateUserSupportResult = Result.error(Exception('x'));

      final result = await repository.updateUserPremium(
        uid: 'uid-1',
        lastPremiumAt: DateTime(2026, 5, 1),
        supportPackage: SupportPackage.weekly,
      );

      expect(result, isA<Error<void>>());
      expect(repository.currentUser.value.isPremium, isFalse);
    });
  });

  group('getFavoritedPostIds', () {
    test('passes the ids through', () async {
      firestore.getFavoritedPostIdsResult = const Ok(['p1', 'p2']);

      final result = await repository.getFavoritedPostIds(uid: 'uid-1');

      expect(result.asOk.value, ['p1', 'p2']);
      expect(firestore.getFavoritedPostIdsUids, ['uid-1']);
    });

    test('passes Ok(null) through when the user has no favourites', () async {
      firestore.getFavoritedPostIdsResult = const Ok(null);

      final result = await repository.getFavoritedPostIds(uid: 'uid-1');

      expect(result, isA<Ok<List<String>?>>());
      expect(result.asOk.value, isNull);
    });

    test('propagates a service error', () async {
      final failure = Exception('x');
      firestore.getFavoritedPostIdsResult = Result.error(failure);

      final result = await repository.getFavoritedPostIds(uid: 'uid-1');

      expect(result, isA<Error<List<String>?>>());
      expect(result.asError.error, same(failure));
    });
  });
}
