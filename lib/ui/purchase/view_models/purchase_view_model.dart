import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../../domain/domain.dart';

class PurchaseViewModel {
  PurchaseViewModel({
    required PurchasePremiumUseCase purchasePremiumUseCase,
    required RestorePurchasesUseCase restorePurchasesUseCase,
    required SyncRevenueCatStatusUseCase syncRevenueCatStatusUseCase,
    required UserRepository userRepository,
  }) : _purchasePremiumUseCase = purchasePremiumUseCase,
       _restorePurchasesUseCase = restorePurchasesUseCase,
       _syncRevenueCatStatusUseCase = syncRevenueCatStatusUseCase,
       _userRepository = userRepository {
    purchaseWeekly = Command0<void>(
      () => _purchase(SupportPackage.weekly),
      debugLabel: 'PurchaseViewModel.purchaseWeekly',
    );
    purchaseYearly = Command0<void>(
      () => _purchase(SupportPackage.yearly),
      debugLabel: 'PurchaseViewModel.purchaseYearly',
    );
    purchaseSelected = Command0<void>(
      () => _purchase(selectedPackage.value),
      debugLabel: 'PurchaseViewModel.purchaseSelected',
    );
    restorePurchases = Command0<void>(
      _restore,
      debugLabel: 'PurchaseViewModel.restorePurchases',
    );
    syncStatus = Command0<void>(
      _sync,
      debugLabel: 'PurchaseViewModel.syncStatus',
    );
  }

  final _log = Logger('PurchaseViewModel');

  final PurchasePremiumUseCase _purchasePremiumUseCase;
  final RestorePurchasesUseCase _restorePurchasesUseCase;
  final SyncRevenueCatStatusUseCase _syncRevenueCatStatusUseCase;
  final UserRepository _userRepository;

  ValueListenable<User> get currentUser => _userRepository.currentUser;

  /// Ekranda seçili olan paket (varsayılan yıllık).
  final ValueNotifier<SupportPackage> selectedPackage =
      ValueNotifier<SupportPackage>(SupportPackage.yearly);

  late final Command0<void> purchaseWeekly;
  late final Command0<void> purchaseYearly;
  late final Command0<void> purchaseSelected;
  late final Command0<void> restorePurchases;
  late final Command0<void> syncStatus;

  Future<Result<void>> _purchase(SupportPackage package) async {
    final result = await _purchasePremiumUseCase.execute(package: package);
    switch (result) {
      case Ok():
        // Satın alma sonrası premium durumunu garanti etmek için bir kez daha sync.
        await _sync();
        return Result.ok(null);
      case Error():
        _log.warning('Purchase failed: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _restore() async {
    final result = await _restorePurchasesUseCase.execute();
    switch (result) {
      case Ok():
        await _sync();
        return Result.ok(null);
      case Error():
        _log.warning('Restore failed: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }

  Future<Result<void>> _sync() async {
    final result = await _syncRevenueCatStatusUseCase.execute();
    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        // Sync hatası satın alma/restore akışını tamamen bozmasın.
        _log.warning('Sync premium status failed: ${result.asError.error}');
        return Result.error(result.asError.error);
    }
  }

  void dispose() {
    purchaseWeekly.dispose();
    purchaseYearly.dispose();
    purchaseSelected.dispose();
    restorePurchases.dispose();
    syncStatus.dispose();
    selectedPackage.dispose();
  }
}

