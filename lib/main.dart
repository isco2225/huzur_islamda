import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huzur_islamda/firebase_options.dart';
import 'package:logging/logging.dart';

import 'app/app.dart';
import 'data/data.dart';

void main() async {
  // Logger'ı sadece debug mode'da aç (production'da kapat)
  if (kDebugMode) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    AppScreen(
      authRepository: AuthRepositoryRemote(
        firebaseAuthService: FirebaseAuthService(),
      ),
      userRepository: UserRepositoryRemote(
        firestoreUserService: FirestoreUserService(),
      ),
    ),
  );
}
