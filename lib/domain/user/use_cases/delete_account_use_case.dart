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
      return Result.error(Exception('Unexpected error: $e'));
    }
  }

  /*Future<Result<void>> execute() async {
    try {
      final currentUserId = _authRepository.auth.value.uid;
      if (currentUserId.isEmpty) {
        return Result.error(Exception('User ID is empty'));
      }
      // TODO: Implement reauthentication with email/password
      await _authRepository.reauthenticate();

      // 1. Delete user from Firestore
      final userResult = await _userRepository.deleteAuthenticatedUser(
        uid: currentUserId,
      );
      switch (userResult) {
        case Ok():
          // Delete user from Auth
          final authResult = await _authRepository.deleteAccount();
          switch (authResult) {
            case Ok():
              return Result.ok(null);
            case Error():
              return Result.error(authResult.asError.error);
          }
        case Error():
          return Result.error(userResult.asError.error);
      }
    } catch (e) {
      return Result.error(Exception('Unexpected error: $e'));
    }
  }*/
}
