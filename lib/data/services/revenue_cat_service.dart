import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class RevenueCatService {
  RevenueCatService() : _log = Logger('RevenueCatService');

  final Logger _log;
  bool _isConfigured = false;

  Future<Result<void>> configure({
    required String apiKey,
    String? appUserId,
  }) async {
    if (_isConfigured) return Result.ok(null);
    try {
      if (kDebugMode) {
        Purchases.setLogLevel(LogLevel.debug);
      } else {
        Purchases.setLogLevel(LogLevel.info);
      }

      final config = PurchasesConfiguration(apiKey);
      if (appUserId != null && appUserId.isNotEmpty) {
        // RevenueCat SDK'da property adı `appUserID`
        config.appUserID = appUserId;
      }
      await Purchases.configure(config);
      _isConfigured = true;
      _log.info('RevenueCat configured');
      return Result.ok(null);
    } catch (e) {
      _log.severe('RevenueCat configure error: $e');
      return Result.error(UserMessageException('Abonelik sistemi başlatılamadı', cause: e));
    }
  }

  Future<Result<void>> logIn({required String appUserId}) async {
    if (appUserId.isEmpty) {
      return Result.error(const UserMessageException('Kullanıcı kimliği boş'));
    }
    try {
      await Purchases.logIn(appUserId);
      _log.info('RevenueCat logged in: $appUserId');
      return Result.ok(null);
    } catch (e) {
      _log.warning('RevenueCat login error: $e');
      return Result.error(UserMessageException('Abonelik hesabına bağlanılamadı', cause: e));
    }
  }

  Future<Result<void>> logOut() async {
    try {
      await Purchases.logOut();
      _log.info('RevenueCat logged out');
      return Result.ok(null);
    } catch (e) {
      _log.warning('RevenueCat logout error: $e');
      return Result.error(UserMessageException('Abonelik oturumu kapatılamadı', cause: e));
    }
  }

  Future<Result<CustomerInfo>> getCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return Result.ok(info);
    } catch (e) {
      _log.warning('RevenueCat getCustomerInfo error: $e');
      return Result.error(UserMessageException('Abonelik bilgisi alınamadı', cause: e));
    }
  }

  Future<Result<bool>> isUserPremium({required String entitlementId}) async {
    if (entitlementId.isEmpty) {
      return Result.error(Exception('Entitlement ID boş'));
    }
    final infoResult = await getCustomerInfo();
    switch (infoResult) {
      case Ok<CustomerInfo>():
        final info = infoResult.asOk.value;
        final entitlement = info.entitlements.active[entitlementId];
        return Result.ok(entitlement != null);
      case Error<CustomerInfo>():
        return Result.error(infoResult.asError.error);
    }
  }

  Future<Result<void>> purchasePremium({
    required SupportPackage package,
    required String entitlementId,
  }) async {
    if (entitlementId.isEmpty) {
      return Result.error(Exception('Entitlement ID boş'));
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        return Result.error(
          const UserMessageException(
            'Abonelik teklifi bulunamadı. Lütfen daha sonra tekrar deneyin.',
          ),
        );
      }

      final Package? selected = _selectPackage(current, package);
      if (selected == null) {
        return Result.error(const UserMessageException('Seçilen abonelik paketi bulunamadı.'));
      }

      // Not: purchases_flutter v9'da yeni purchase API'si mevcut, ancak projede
      // geriye dönük uyumluluk için `purchasePackage` kullanıyoruz.
      final purchaseResult = await Purchases.purchasePackage(selected);
      final info = purchaseResult.customerInfo;
      final entitlement = info.entitlements.active[entitlementId];
      if (entitlement == null) {
        return Result.error(
          const UserMessageException(
            'Satın alma tamamlandı ancak premium etkinleşmedi.',
          ),
        );
      }
      return Result.ok(null);
    } on PlatformException catch (e) {
      // Kullanıcı iptal ettiyse bunu hata gibi göstermeyelim.
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return Result.error(const UserMessageException('Satın alma iptal edildi'));
      }
      _log.warning('RevenueCat purchase platform error: $e');
      return Result.error(
        UserMessageException('Satın alma başarısız', cause: e.message ?? e.code),
      );
    } catch (e) {
      _log.warning('RevenueCat purchase error: $e');
      return Result.error(UserMessageException('Satın alma başarısız', cause: e));
    }
  }

  Future<Result<void>> restorePurchases({required String entitlementId}) async {
    if (entitlementId.isEmpty) {
      return Result.error(Exception('Entitlement ID boş'));
    }
    try {
      final info = await Purchases.restorePurchases();
      final entitlement = info.entitlements.active[entitlementId];
      if (entitlement == null) {
        return Result.error(
          const UserMessageException(
            'Geri yükleme tamamlandı ancak aktif abonelik bulunamadı',
          ),
        );
      }
      return Result.ok(null);
    } on PlatformException catch (e) {
      _log.warning('RevenueCat restore platform error: $e');
      return Result.error(
        UserMessageException('Geri yükleme başarısız', cause: e.message ?? e.code),
      );
    } catch (e) {
      _log.warning('RevenueCat restore error: $e');
      return Result.error(UserMessageException('Geri yükleme başarısız', cause: e));
    }
  }

  Package? _selectPackage(Offering offering, SupportPackage package) {
    // RevenueCat paket tipleri: weekly / monthly / annual vb.
    // Mevcut domain enum'u (weekly/yearly) ile eşleştiriyoruz.
    final targetType = switch (package) {
      SupportPackage.weekly => PackageType.weekly,
      SupportPackage.yearly => PackageType.annual,
    };

    for (final p in offering.availablePackages) {
      if (p.packageType == targetType) return p;
    }

    // Fallback: ilk paket.
    if (offering.availablePackages.isNotEmpty) {
      return offering.availablePackages.first;
    }
    return null;
  }
}
