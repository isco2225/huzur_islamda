import 'package:firebase_auth/firebase_auth.dart';

import '../../app/app.dart';
import '../../domain/domain.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Result<Consumer>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String dateOfBirth,
    required String maritalStatus,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = result.user;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }

    return Result.ok(
      Consumer(
        uid: user.uid,
        email: user.email,
        name: name,
        dateOfBirth: DateTime.parse(dateOfBirth),
        maritalStatus: maritalStatus,
      ),
    );
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user?.reload();
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
