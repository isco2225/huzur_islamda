import '../../../app/app.dart';
import '../../../data/data.dart';

class CreateUserProfileUseCase {
  CreateUserProfileUseCase({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _userRepository = userRepository,
       _authRepository = authRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  Future<Result<void>> execute({
    required String name,
    required String surname,
    required String dateOfBirth,
    required String gender,
  }) async {
    try {
      final result = await _userRepository.createUser(
        uid: _authRepository.auth.value.uid,
        email: _authRepository.auth.value.email,
        name: name,
        surname: surname,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      switch (result) {
        case Ok():
          return Result.ok(null);
        case Error():
          return Result.error(result.asError.error);
      }
    } catch (e) {
      return Result.error(Exception(e));
    }
  }
}
