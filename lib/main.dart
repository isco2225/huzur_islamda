import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huzur_islamda/firebase_options.dart';
import 'package:logging/logging.dart';

import 'app/app.dart';
import 'data/data.dart';
import 'domain/domain.dart';

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

  // Hive Services
  final hiveDhikr = HiveService<Dhikr>(Dhikr.boxName);
  final hivePrayer = HiveService<Prayer>(Prayer.boxName);

  // Services
  final prayerService = PrayerService();

  // Repositories
  final authRepository = AuthRepositoryRemote(
    firebaseAuthService: FirebaseAuthService(),
  );
  final dhikrRepository = DhikrRepositoryRemote(
    hiveService: hiveDhikr,
    firestoreDhikrService: FirestoreDhikrService(),
  );
  final prayerRepository = PrayerRepositoryRemote(
    hiveService: hivePrayer,
    prayerService: prayerService,
  );

  // Use Cases
  final connectivityUseCase = ConnectivityUseCase();
  final prayerTimeUseCase = PrayerTimeUseCase(
    prayerRepository: prayerRepository,
    connectivityUseCase: connectivityUseCase,
  );

  runApp(
    AppScreen(
      authRepository: authRepository,
      userRepository: UserRepositoryRemote(
        firestoreUserService: FirestoreUserService(),
      ),
      postRepository: PostRepositoryRemote(
        firestorePostService: FirestorePostService(),
      ),
      dhikrRepository: dhikrRepository,
      dhikrUseCase: DhikrUseCase(
        dhikrRepository: dhikrRepository,
        connectivityUseCase: connectivityUseCase,
        authRepository: authRepository,
      ),
      placesRepository: PlacesRepositoryRemote(
        placeSelectorService: PlaceSelectorService(),
      ),
      connectivityUseCase: connectivityUseCase,
      prayerRepository: prayerRepository,
      prayerTimeUseCase: prayerTimeUseCase,
      hiveDhikr: hiveDhikr,
    ),
  );
}
