import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppPurchaseConfig {
  AppPurchaseConfig._();

  static String get revenueCatApiKey {
    final String? key = Platform.isIOS
        ? dotenv.env['REVENUECAT_IOS_API_KEY']
        : dotenv.env['REVENUECAT_ANDROID_API_KEY'];

    if (key == null || key.isEmpty) {
      throw Exception(
        'RevenueCat API anahtarı bulunamadı. `.env` içine '
        '${Platform.isIOS ? 'REVENUECAT_IOS_API_KEY' : 'REVENUECAT_ANDROID_API_KEY'} ekleyin.',
      );
    }
    return key;
  }

  static String get entitlementId {
    final String? entitlementId = dotenv.env['REVENUECAT_ENTITLEMENT_ID'];
    if (entitlementId == null || entitlementId.isEmpty) {
      throw Exception(
        'RevenueCat entitlement ID bulunamadı. `.env` içine REVENUECAT_ENTITLEMENT_ID ekleyin.',
      );
    }
    return entitlementId;
  }

  static String? get weeklyProductId {
    final v = dotenv.env['REVENUECAT_PRODUCT_ID_WEEKLY'];
    return (v == null || v.isEmpty) ? null : v;
  }

  static String? get yearlyProductId {
    final v = dotenv.env['REVENUECAT_PRODUCT_ID_YEARLY'];
    return (v == null || v.isEmpty) ? null : v;
  }
}
