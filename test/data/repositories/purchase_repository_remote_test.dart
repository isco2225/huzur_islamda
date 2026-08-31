import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/errors/models/user_message_exception.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/data/data.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/fakes/fake_services.dart';
import '../../helpers/fixtures.dart';

/// Only the `_ensureLoggedIn` gate is covered. Everything past it needs a
/// RevenueCat `CustomerInfo` (entitlement mapping, package resolution), which
/// cannot be constructed outside the SDK, so [FakeRevenueCatService] throws
/// if any of those methods is reached.
void main() {
  late FakeRevenueCatService revenueCat;
  late FakeFirebaseAuthService authService;
  late FakeFirestoreUserService userService;
  late AuthRepositoryRemote authRepository;
  late UserRepositoryRemote userRepository;
  late PurchaseRepositoryRemote repository;

  setUp(() {
    revenueCat = FakeRevenueCatService();
    authService = FakeFirebaseAuthService();
    userService = FakeFirestoreUserService();
    authRepository = AuthRepositoryRemote(
      firebaseAuthService: authService,
      firebaseCloudFunctionsService: FakeFirebaseCloudFunctionsService(),
    );
    userRepository = UserRepositoryRemote(firestoreUserService: userService);
    repository = PurchaseRepositoryRemote(
      revenueCatService: revenueCat,
      authRepository: authRepository,
      userRepository: userRepository,
      entitlementId: 'premium',
    );
  });

  Future<void> signIn() async {
    authService.signInResult = Result.ok(Fixtures.auth(uid: 'uid-1'));
    await authRepository.signIn(email: 'test@example.com', password: 'pw');
  }

  void expectNotLoggedIn(Result<Object?> result) {
    expect(result, isA<Error<Object?>>());
    expect(result.asError.error, isA<UserMessageException>());
    expect(
      (result.asError.error as UserMessageException).message,
      'Kullanıcı oturum açmamış',
    );
    expect(revenueCat.logInUserIds, isEmpty);
  }

  group('when nobody is signed in', () {
    test('isUserPremium fails without touching RevenueCat', () async {
      expectNotLoggedIn(await repository.isUserPremium());
    });

    test('purchasePremium fails without touching RevenueCat', () async {
      expectNotLoggedIn(await repository.purchasePremium(SupportPackage.yearly));
    });

    test('restorePurchases fails without touching RevenueCat', () async {
      expectNotLoggedIn(await repository.restorePurchases());
    });

    test('syncPremiumStatusWithBackend fails without touching RevenueCat', () async {
      expectNotLoggedIn(await repository.syncPremiumStatusWithBackend());
      expect(userService.updateUserSupportCalls, isEmpty);
    });
  });

  group('when signed in', () {
    setUp(() async {
      await signIn();
    });

    test('logs the uid into RevenueCat before doing anything else', () async {
      final failure = Exception('Abonelik hesabına bağlanılamadı');
      revenueCat.logInResult = Result.error(failure);

      final result = await repository.isUserPremium();

      expect(result, isA<Error<bool>>());
      expect(result.asError.error, same(failure));
      expect(revenueCat.logInUserIds, ['uid-1']);
    });

    test('a RevenueCat login failure short-circuits purchasePremium', () async {
      revenueCat.logInResult = Result.error(Exception('x'));

      final result = await repository.purchasePremium(SupportPackage.weekly);

      expect(result, isA<Error<void>>());
      expect(revenueCat.logInUserIds, ['uid-1']);
    });

    test('a RevenueCat login failure short-circuits restorePurchases', () async {
      revenueCat.logInResult = Result.error(Exception('x'));

      final result = await repository.restorePurchases();

      expect(result, isA<Error<void>>());
      expect(revenueCat.logInUserIds, ['uid-1']);
    });

    test(
      'a RevenueCat login failure short-circuits syncPremiumStatusWithBackend '
      'before Firestore is touched',
      () async {
        revenueCat.logInResult = Result.error(Exception('x'));

        final result = await repository.syncPremiumStatusWithBackend();

        expect(result, isA<Error<void>>());
        expect(revenueCat.logInUserIds, ['uid-1']);
        expect(userService.updateUserSupportCalls, isEmpty);
      },
    );

    test('signing out re-arms the gate', () async {
      await authRepository.signOut();

      expectNotLoggedIn(await repository.isUserPremium());
    });
  });
}
