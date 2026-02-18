import '../../../app/app.dart';
import '../../../data/data.dart';
import '../../domain.dart';

class PurchasePremiumUseCase {
  PurchasePremiumUseCase({required PurchaseRepository purchaseRepository})
    : _purchaseRepository = purchaseRepository;

  final PurchaseRepository _purchaseRepository;

  Future<Result<void>> execute({required SupportPackage package}) async {
    try {
      return await _purchaseRepository.purchasePremium(package);
    } catch (e) {
      return Result.error(Exception('Satın alma başlatılamadı: $e'));
    }
  }
}

