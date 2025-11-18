import '../../../app/app.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../models/models.dart';

/// Sign up işlemini gerçekleştiren UseCase
///
/// İki repository'yi koordine eder:
/// 1. AuthRepository: Firebase Auth'da kullanıcı oluşturur
/// 2. UserRepository: Firestore'a kullanıcı bilgilerini kaydeder
class SignUpUseCase {
  SignUpUseCase({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<Result<Consumer>> execute({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String dateOfBirth,
    required String maritalStatus,
  }) async {
    // 1. Firebase Auth'da kullanıcı oluştur (email doğrulama otomatik gönderilir)
    final authResult = await _authRepository.requestSignUp(
      email: email,
      password: password,
      name: name,
      surname: surname,
      dateOfBirth: dateOfBirth,
      maritalStatus: maritalStatus,
    );

    switch (authResult) {
      case Ok():
        final consumer = authResult.asOk.value;

        // 2. Kullanıcıyı Firestore'a kaydet (emailVerified: false olarak)
        final firestoreResult = await _userRepository.createUser(
          uid: consumer.uid,
          email: consumer.email,
          name: name,
          surname: surname,
          dateOfBirth: dateOfBirth,
          maritalStatus: maritalStatus,
        );

        switch (firestoreResult) {
          case Ok():
            // Başarılı - Consumer objesini genişletilmiş bilgilerle döndür
            return Result.ok(
              consumer.copyWith(
                name: name,
                surname: surname,
                dateOfBirth: dateOfBirth,
                maritalStatus: maritalStatus,
                emailVerified: false,
              ),
            );
          case Error():
            // Firestore'a kaydetme başarısız oldu
            // Ama kullanıcı Firebase Auth'da oluşturuldu
            return Result.error(
              Exception(
                'Kullanıcı oluşturuldu ancak bilgiler kaydedilemedi: ${firestoreResult.asError.error}',
              ),
            );
        }
      case Error():
        return Result.error(authResult.asError.error);
    }
  }
}
