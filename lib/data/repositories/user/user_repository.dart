import 'package:flutter/foundation.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class UserRepository {
  /// Get current user's UID
  ValueListenable<User> get currentUser;

  /// Kullanıcıyı Firestore'a kaydet
  Future<Result<User>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String gender,
  });

  /// Kullanıcının email doğrulama durumunu güncelle
  Future<Result<void>> updateEmailVerificationStatus({
    required String uid,
    required bool emailVerified,
  });

  /// Kullanıcı bilgilerini güncelle
  Future<Result<void>> updateUser({
    required String uid,
    String? name,
    String? surname,
    String? dateOfBirth,
    String? gender,
  });

  /// Kullanıcının favori post'larının ids'ini getir
  Future<Result<List<String>?>> getFavoritedPostIds({required String uid});

  /// Kullanıcı bilgilerini Firestore'dan getir
  Future<Result<bool>> fetchAuthenticatedUser({required String uid});

  /// Kullanıcıyı Firestore'dan sil
  Future<Result<void>> deleteAuthenticatedUser({required String uid});

  /// Kullanıcı bilgilerini temizle (wipe)
  void wipeUser();

  Future<Result<bool>> initUser({required String uid});

  Future<Result<void>> updateUserLocation({
    required String uid,
    required String country,
    required String city,
    required String districtId,
  });

  Future<Result<void>> updateUserSupport({
    required String uid,
    required bool hasSupported,
    required DateTime lastSupportedAt,
    required SupportPackage supportPackage,
  });
}
