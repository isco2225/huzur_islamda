import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Result<Consumer>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = result.user;
    if (user == null) {
      return Result.error(Exception('Failed to sign up'));
    }

    return Result.ok(Consumer(uid: user.uid, email: user.email!));
  }

  Future<Result<Consumer>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final consumer = result.user;
    if (consumer == null) {
      return Result.error(Exception('Failed to sign in'));
    }
    return Result.ok(Consumer(uid: consumer.uid, email: consumer.email!));
  }

  Future<Result<void>> signOut() async {
    await _auth.signOut();
    return Result.ok(null);
  }

  User? get currentUser => _auth.currentUser;
}
