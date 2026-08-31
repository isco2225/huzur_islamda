import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/utils/result.dart';
import 'package:huzur_islamda/domain/domain.dart';
import 'package:huzur_islamda/ui/ui.dart';

import '../../../helpers/helpers.dart';

void main() {
  late FakePurchaseRepository purchaseRepository;
  late FakeUserRepository userRepository;
  late PurchaseViewModel viewModel;

  setUp(() {
    purchaseRepository = FakePurchaseRepository();
    userRepository = FakeUserRepository(currentUser: Fixtures.user());
    viewModel = PurchaseViewModel(
      purchasePremiumUseCase: PurchasePremiumUseCase(
        purchaseRepository: purchaseRepository,
      ),
      restorePurchasesUseCase: RestorePurchasesUseCase(
        purchaseRepository: purchaseRepository,
      ),
      syncRevenueCatStatusUseCase: SyncRevenueCatStatusUseCase(
        purchaseRepository: purchaseRepository,
      ),
      userRepository: userRepository,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('defaults to the yearly package and mirrors the current user', () {
    expect(viewModel.selectedPackage.value, SupportPackage.yearly);
    expect(viewModel.currentUser, same(userRepository.currentUserNotifier));
  });

  group('purchaseWeekly / purchaseYearly', () {
    test('purchaseWeekly buys the weekly package then syncs the backend', () async {
      await viewModel.purchaseWeekly.execute();

      expect(purchaseRepository.calls, [
        'purchasePremium(package=weekly)',
        'syncPremiumStatusWithBackend()',
      ]);
      expect(viewModel.purchaseWeekly.completed.value, isTrue);
    });

    test('purchaseYearly buys the yearly package then syncs the backend', () async {
      await viewModel.purchaseYearly.execute();

      expect(purchaseRepository.calls, [
        'purchasePremium(package=yearly)',
        'syncPremiumStatusWithBackend()',
      ]);
      expect(viewModel.purchaseYearly.completed.value, isTrue);
    });

    test('propagates a purchase error and does not sync', () async {
      final exception = Exception('cancelled');
      purchaseRepository.purchasePremiumResult = Error<void>(exception);

      await viewModel.purchaseWeekly.execute();

      expect(viewModel.purchaseWeekly.error.value, isTrue);
      expect(viewModel.purchaseWeekly.result.value!.asError.error, same(exception));
      expect(purchaseRepository.calls, ['purchasePremium(package=weekly)']);
    });

    test('wraps a thrown SDK error through the use case', () async {
      purchaseRepository.throwOnCall = StateError('sdk');

      await viewModel.purchaseYearly.execute();

      expect(viewModel.purchaseYearly.error.value, isTrue);
      expect(
        viewModel.purchaseYearly.result.value!.asError.error.toString(),
        contains('Satın alma başlatılamadı'),
      );
    });

    // The sync step's result is deliberately ignored after a successful
    // purchase (see the comment in `_purchase`), so the command still
    // completes with Ok.
    test('a failing post-purchase sync still yields Ok', () async {
      purchaseRepository.syncPremiumStatusWithBackendResult = Error<void>(
        Exception('backend'),
      );

      await viewModel.purchaseWeekly.execute();

      expect(viewModel.purchaseWeekly.completed.value, isTrue);
      expect(purchaseRepository.calls, hasLength(2));
    });
  });

  group('purchaseSelected', () {
    test('uses the package currently selected on screen', () async {
      viewModel.selectedPackage.value = SupportPackage.weekly;

      await viewModel.purchaseSelected.execute();

      expect(purchaseRepository.calls.first, 'purchasePremium(package=weekly)');
    });

    test('defaults to yearly when nothing was changed', () async {
      await viewModel.purchaseSelected.execute();

      expect(purchaseRepository.calls.first, 'purchasePremium(package=yearly)');
    });
  });

  group('restorePurchases', () {
    test('restores then syncs the backend', () async {
      await viewModel.restorePurchases.execute();

      expect(purchaseRepository.calls, [
        'restorePurchases()',
        'syncPremiumStatusWithBackend()',
      ]);
      expect(viewModel.restorePurchases.completed.value, isTrue);
    });

    test('propagates a restore error and does not sync', () async {
      final exception = Exception('nothing to restore');
      purchaseRepository.restorePurchasesResult = Error<void>(exception);

      await viewModel.restorePurchases.execute();

      expect(viewModel.restorePurchases.error.value, isTrue);
      expect(viewModel.restorePurchases.result.value!.asError.error, same(exception));
      expect(purchaseRepository.calls, ['restorePurchases()']);
    });
  });

  group('syncStatus', () {
    test('syncs the backend and completes on Ok', () async {
      await viewModel.syncStatus.execute();

      expect(purchaseRepository.calls, ['syncPremiumStatusWithBackend()']);
      expect(viewModel.syncStatus.completed.value, isTrue);
    });

    test('propagates a sync error when invoked directly', () async {
      final exception = Exception('backend');
      purchaseRepository.syncPremiumStatusWithBackendResult = Error<void>(exception);

      await viewModel.syncStatus.execute();

      expect(viewModel.syncStatus.error.value, isTrue);
      expect(viewModel.syncStatus.result.value!.asError.error, same(exception));
    });
  });
}
