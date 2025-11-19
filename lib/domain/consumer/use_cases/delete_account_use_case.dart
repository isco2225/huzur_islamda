import '../../../app/app.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/user/user_repository.dart';

/// Kullanıcı hesabını silen UseCase
///
/// İki repository'yi koordine eder:
/// 1. UserRepository: Firestore'dan kullanıcıyı siler
/// 2. AuthRepository: Firebase Auth'dan kullanıcıyı siler ve sign out yapar
class DeleteAccountUseCase {
  DeleteAccountUseCase({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<Result<void>> execute() async {
    try {
      final currentUserId = _authRepository.currentUserId.value;

      if (currentUserId == null) {
        return Result.error(Exception('No user is currently signed in'));
      }

      // 1. Önce Firestore'dan kullanıcıyı sil
      // (Eğer Auth silme başarısız olursa, en azından Firestore'da orphan data kalmaz)
      final firestoreResult = await _userRepository.deleteUser(currentUserId);

      // Firestore silme başarısız olsa bile Auth silmeyi dene
      // (Kullanıcı zaten Auth'da varsa, Firestore'da olmayabilir)
      final authResult = await _authRepository.deleteAccount();

      switch (authResult) {
        case Ok():
          // Auth silme başarılı - Firestore sonucu önemli değil
          return Result.ok(null);
        case Error():
          // Auth silme başarısız - Firestore sonucunu da kontrol et
          if (firestoreResult is Error<void>) {
            return Result.error(
              Exception(
                'Failed to delete account: ${authResult.asError.error}. Also failed to delete from Firestore: ${firestoreResult.asError.error}',
              ),
            );
          }
          // Firestore başarılı ama Auth başarısız
          return Result.error(authResult.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Unexpected error: $e'));
    }
  }
}
