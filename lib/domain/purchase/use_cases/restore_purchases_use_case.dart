import '../../../app/app.dart';
import '../../../data/data.dart';

class RestorePurchasesUseCase {
  RestorePurchasesUseCase({required PurchaseRepository purchaseRepository})
    : _purchaseRepository = purchaseRepository;

  final PurchaseRepository _purchaseRepository;

  Future<Result<void>> execute() async {
    try {
      return await _purchaseRepository.restorePurchases();
    } catch (e) {
      return Result.error(UserMessageException('Satın alımlar geri yüklenemedi', cause: e));
    }
  }
}

