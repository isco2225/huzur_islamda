import '../../../app/app.dart';
import '../../../domain/domain.dart';

abstract class UserRepository {
  /// Kullanıcıyı Firestore'a kaydet
  Future<Result<void>> createUser({
    required String uid,
    required String email,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
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
    String? maritalStatus,
  });

  /// Kullanıcı bilgilerini Firestore'dan getir
  Future<Result<Consumer>> getUser(String uid);
}
