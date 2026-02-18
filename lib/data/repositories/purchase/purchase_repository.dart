import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class PurchaseRepository {
  /// RevenueCat üzerinden premium durumu.
  Future<Result<bool>> isUserPremium();

  /// Seçilen paketi satın alır.
  Future<Result<void>> purchasePremium(SupportPackage package);

  /// Satın alımları geri yükler.
  Future<Result<void>> restorePurchases();

  /// RevenueCat durumunu backend (Firestore) ile senkronize eder.
  Future<Result<void>> syncPremiumStatusWithBackend();
}

