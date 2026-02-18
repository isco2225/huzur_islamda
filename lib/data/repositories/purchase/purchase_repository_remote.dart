import 'package:logging/logging.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../services/revenue_cat_service.dart';
import '../auth/auth.dart';
import '../user/user.dart';
import 'purchase_repository.dart';

class PurchaseRepositoryRemote extends PurchaseRepository {
  PurchaseRepositoryRemote({
    required RevenueCatService revenueCatService,
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required String entitlementId,
    String? weeklyProductId,
    String? yearlyProductId,
  }) : _revenueCatService = revenueCatService,
       _authRepository = authRepository,
       _userRepository = userRepository,
       _entitlementId = entitlementId,
       _weeklyProductId = weeklyProductId,
       _yearlyProductId = yearlyProductId;

  final Logger _log = Logger('PurchaseRepositoryRemote');
  final RevenueCatService _revenueCatService;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final String _entitlementId;
  final String? _weeklyProductId;
  final String? _yearlyProductId;

  String get _uid => _authRepository.auth.value.uid;

  Future<Result<void>> _ensureLoggedIn() async {
    final uid = _uid;
    if (uid.isEmpty) {
      return Result.error(Exception('Kullanıcı oturum açmamış'));
    }
    return _revenueCatService.logIn(appUserId: uid);
  }

  @override
  Future<Result<bool>> isUserPremium() async {
    final loginResult = await _ensureLoggedIn();
    if (loginResult case Error()) {
      return Result.error(loginResult.asError.error);
    }
    return _revenueCatService.isUserPremium(entitlementId: _entitlementId);
  }

  @override
  Future<Result<void>> purchasePremium(SupportPackage package) async {
    final loginResult = await _ensureLoggedIn();
    if (loginResult case Error()) {
      return Result.error(loginResult.asError.error);
    }
    final purchaseResult = await _revenueCatService.purchasePremium(
      package: package,
      entitlementId: _entitlementId,
    );
    switch (purchaseResult) {
      case Ok():
        // Satın alma sonrası durumu Firestore ile senkronla
        final syncResult = await _syncPremiumStatusWithBackend(
          fallbackPackage: package,
        );
        return syncResult;
      case Error():
        return Result.error(purchaseResult.asError.error);
    }
  }

  @override
  Future<Result<void>> restorePurchases() async {
    final loginResult = await _ensureLoggedIn();
    if (loginResult case Error()) {
      return Result.error(loginResult.asError.error);
    }
    final restoreResult = await _revenueCatService.restorePurchases(
      entitlementId: _entitlementId,
    );
    switch (restoreResult) {
      case Ok():
        return syncPremiumStatusWithBackend();
      case Error():
        return Result.error(restoreResult.asError.error);
    }
  }

  @override
  Future<Result<void>> syncPremiumStatusWithBackend() async {
    return _syncPremiumStatusWithBackend(fallbackPackage: SupportPackage.yearly);
  }

  Future<Result<void>> _syncPremiumStatusWithBackend({
    required SupportPackage fallbackPackage,
  }) async {
    final loginResult = await _ensureLoggedIn();
    if (loginResult case Error()) {
      return Result.error(loginResult.asError.error);
    }

    final infoResult = await _revenueCatService.getCustomerInfo();
    switch (infoResult) {
      case Ok():
        final info = infoResult.asOk.value;
        final isPremium = info.entitlements.active[_entitlementId] != null;
        _log.info('RevenueCat premium: $isPremium');
        if (!isPremium) {
          // Premium yoksa Firestore'u zorla kapatmayalım (ör. grace period vs.)
          // Şimdilik sadece premium olduğunda güncelliyoruz.
          return Result.ok(null);
        }

        final SupportPackage resolved = _resolveSupportPackageFromInfo(
          info,
          fallbackPackage: fallbackPackage,
        );

        final uid = _uid;
        final now = DateTime.now();
        final updateResult = await _userRepository.updateUserPremium(
          uid: uid,
          lastPremiumAt: now,
          supportPackage: resolved,
        );
        return updateResult;
      case Error():
        return Result.error(infoResult.asError.error);
    }
  }

  SupportPackage _resolveSupportPackageFromInfo(
    dynamic customerInfo, {
    required SupportPackage fallbackPackage,
  }) {
    try {
      // purchases_flutter CustomerInfo: activeSubscriptions -> List<String>
      final List<String> activeSubscriptions =
          (customerInfo.activeSubscriptions as List<dynamic>)
              .map((e) => e.toString())
              .toList();
      if (activeSubscriptions.isEmpty) return fallbackPackage;

      if (_weeklyProductId != null &&
          activeSubscriptions.contains(_weeklyProductId)) {
        return SupportPackage.weekly;
      }
      if (_yearlyProductId != null &&
          activeSubscriptions.contains(_yearlyProductId)) {
        return SupportPackage.yearly;
      }

      // Heuristik: product id içinde weekly/yearly geçiyorsa.
      if (activeSubscriptions.any((id) => id.toLowerCase().contains('week'))) {
        return SupportPackage.weekly;
      }
      if (activeSubscriptions.any((id) => id.toLowerCase().contains('year'))) {
        return SupportPackage.yearly;
      }
      return fallbackPackage;
    } catch (_) {
      return fallbackPackage;
    }
  }
}

