import '../../../app/app.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/user/user_repository.dart';

/// Email doğrulama durumunu kontrol eden UseCase
///
/// İki repository'yi koordine eder:
/// 1. AuthRepository: Firebase Auth'dan email doğrulama durumunu kontrol eder
/// 2. UserRepository: Firestore'da email doğrulama durumunu günceller
class CheckEmailVerificationUseCase {
  CheckEmailVerificationUseCase({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<Result<bool>> execute() async {
    // 1. Firebase Auth'dan email doğrulama durumunu kontrol et
    final authResult = await _authRepository.checkEmailVerification();

    switch (authResult) {
      case Ok():
        final isVerified = authResult.asOk.value;
        final currentUserId = _authRepository.auth.value.uid;

        // 2. Email doğrulandıysa Firestore'da da güncelle
        if (isVerified) {
          await _userRepository.updateEmailVerificationStatus(
            uid: currentUserId,
            emailVerified: true,
          );
        }

        return Result.ok(isVerified);
      case Error():
        return Result.error(authResult.asError.error);
    }
  }
}
