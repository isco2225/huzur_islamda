import '../../../app/app.dart';
import '../../../data/data.dart';

class DeleteAccountUseCase {
  DeleteAccountUseCase({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  Future<Result<void>> execute() async {
    try {
      final deleteAccountResult = await _authRepository.deleteAccount();
      switch (deleteAccountResult) {
        case Ok():
          await _authRepository.signOut();
          return Result.ok(null);
        case Error():
          return Result.error(deleteAccountResult.asError.error);
      }
    } catch (e) {
      return Result.error(
        UserMessageException('Hesap silinirken bir hata oluştu', cause: e),
      );
    }
  }
}
