import 'package:huzur_islamda/data/repositories/auth/auth_repository.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../services/services.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({required FirebaseAuthService firebaseAuthService})
    : _firebaseAuthService = firebaseAuthService;
  final FirebaseAuthService _firebaseAuthService;

  @override
  Future<Result<Consumer>> signIn({
    required String email,
    required String password,
  }) {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<Result<Consumer>> requestSignUp({
    required String email,
    required String password,
  }) {
    // TODO: implement requestSignUp
    throw UnimplementedError();
  }

  @override
  Future<Result<Consumer>> createAccount({
    required String email,
    required String verificationCode,
  }) {
    // TODO: implement createAccount
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> sendPasswordResetCode({required String email}) {
    // TODO: implement sendPasswordResetCode
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
