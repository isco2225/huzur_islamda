import '../../../app/app.dart';
import '../../../data/data.dart';

class SyncRevenueCatStatusUseCase {
  SyncRevenueCatStatusUseCase({required PurchaseRepository purchaseRepository})
    : _purchaseRepository = purchaseRepository;

  final PurchaseRepository _purchaseRepository;

  Future<Result<void>> execute() async {
    try {
      return await _purchaseRepository.syncPremiumStatusWithBackend();
    } catch (e) {
      return Result.error(Exception('Premium durumu senkronize edilemedi: $e'));
    }
  }
}

