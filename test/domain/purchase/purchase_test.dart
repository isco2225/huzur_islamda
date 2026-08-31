import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';

import '../../helpers/helpers.dart';

void main() {
  group('SupportPackage', () {
    test('value matches the enum name', () {
      expect(SupportPackage.yearly.value, 'yearly');
      expect(SupportPackage.weekly.value, 'weekly');
    });

    test('fromString resolves known values', () {
      expect(SupportPackage.fromString('yearly'), SupportPackage.yearly);
      expect(SupportPackage.fromString('weekly'), SupportPackage.weekly);
    });

    test('fromString returns null for null, empty or unknown values', () {
      expect(SupportPackage.fromString(null), isNull);
      expect(SupportPackage.fromString(''), isNull);
      expect(SupportPackage.fromString('monthly'), isNull);
      expect(SupportPackage.fromString('Yearly'), isNull);
    });

    test('round-trips every package through its value', () {
      for (final package in SupportPackage.values) {
        expect(SupportPackage.fromString(package.value), package);
      }
    });
  });

  group('PurchasePremiumUseCase', () {
    late FakePurchaseRepository repository;
    late PurchasePremiumUseCase useCase;

    setUp(() {
      repository = FakePurchaseRepository();
      useCase = PurchasePremiumUseCase(purchaseRepository: repository);
    });

    test('passes the package through and returns Ok', () async {
      final result = await useCase.execute(package: SupportPackage.weekly);

      expect(result, isA<Ok<void>>());
      expect(repository.calls, ['purchasePremium(package=weekly)']);
    });

    test('passes a repository error through unchanged', () async {
      final exception = Exception('cancelled');
      repository.purchasePremiumResult = Error(exception);

      final result = await useCase.execute(package: SupportPackage.yearly);

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('wraps a thrown exception with the Turkish message', () async {
      repository.throwOnCall = Exception('sdk');

      final result = await useCase.execute(package: SupportPackage.yearly);

      expect(result, isA<Error<void>>());
      expect(
        result.asError.error.toString(),
        allOf(contains('Satın alma başlatılamadı'), contains('sdk')),
      );
    });
  });

  group('RestorePurchasesUseCase', () {
    late FakePurchaseRepository repository;
    late RestorePurchasesUseCase useCase;

    setUp(() {
      repository = FakePurchaseRepository();
      useCase = RestorePurchasesUseCase(purchaseRepository: repository);
    });

    test('delegates and returns Ok', () async {
      final result = await useCase.execute();

      expect(result, isA<Ok<void>>());
      expect(repository.calls, ['restorePurchases()']);
    });

    test('passes a repository error through unchanged', () async {
      final exception = Exception('nothing to restore');
      repository.restorePurchasesResult = Error(exception);

      final result = await useCase.execute();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('wraps a thrown exception with the Turkish message', () async {
      repository.throwOnCall = StateError('sdk');

      final result = await useCase.execute();

      expect(result, isA<Error<void>>());
      expect(
        result.asError.error.toString(),
        contains('Satın alımlar geri yüklenemedi'),
      );
    });
  });

  group('SyncRevenueCatStatusUseCase', () {
    late FakePurchaseRepository repository;
    late SyncRevenueCatStatusUseCase useCase;

    setUp(() {
      repository = FakePurchaseRepository();
      useCase = SyncRevenueCatStatusUseCase(purchaseRepository: repository);
    });

    test('delegates and returns Ok', () async {
      final result = await useCase.execute();

      expect(result, isA<Ok<void>>());
      expect(repository.calls, ['syncPremiumStatusWithBackend()']);
    });

    test('passes a repository error through unchanged', () async {
      final exception = Exception('backend');
      repository.syncPremiumStatusWithBackendResult = Error(exception);

      final result = await useCase.execute();

      expect(result, isA<Error<void>>());
      expect(result.asError.error, same(exception));
    });

    test('wraps a thrown exception with the Turkish message', () async {
      repository.throwOnCall = Exception('sdk');

      final result = await useCase.execute();

      expect(result, isA<Error<void>>());
      expect(
        result.asError.error.toString(),
        contains('Premium durumu senkronize edilemedi'),
      );
    });
  });
}
