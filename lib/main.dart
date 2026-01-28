import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  await dotenv.load();
  // Hive Services
  final hiveDhikr = HiveService<Dhikr>(Dhikr.boxName);
  final hivePrayer = HiveService<Prayer>(Prayer.boxName);

  // Services
  final prayerService = PrayerService();
  final notificationService = NotificationService();
  final admobService = AdMobService();

  // Initialize notification service
  final notificationInitResult = await notificationService.initialize();
  switch (notificationInitResult) {
    case Ok():
      debugPrint('Notification service initialized successfully');
      break;
    case Error():
      debugPrint(
        'Failed to initialize notification service: ${notificationInitResult.asError.error}',
      );
      break;
  }

  // Initialize AdMob service
  final admobInitResult = await admobService.initialize();
  switch (admobInitResult) {
    case Ok():
      debugPrint('AdMob service initialized successfully');
      break;
    case Error():
      debugPrint(
        'Failed to initialize AdMob service: ${admobInitResult.asError.error}',
      );
      break;
  }

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
  final notificationRepository = NotificationRepositoryRemote(
    notificationService: notificationService,
  );
  final userRepository = UserRepositoryRemote(
    firestoreUserService: FirestoreUserService(),
  );

  // Use Cases
  final connectivityUseCase = ConnectivityUseCase();
  final prayerTimeUseCase = PrayerTimeUseCase(
    prayerRepository: prayerRepository,
    connectivityUseCase: connectivityUseCase,
  );
  final requestPermissionUseCase =
      RequestPermissionUseCase.withPermissionHandler();
  final getPermissionStatesUseCase =
      GetPermissionStatesUseCase.withPermissionHandler();
  final schedulePrayerNotificationsUseCase = SchedulePrayerNotificationsUseCase(
    prayerRepository: prayerRepository,
    notificationRepository: notificationRepository,
    userRepository: userRepository,
  );
  final appRepository = AppRepositoryRemote(
    sharedPreferencesService: SharedPreferencesService(),
  );
  final wipeDataUseCase = WipeDataUseCase(
    dhikrRepository: dhikrRepository,
    prayerRepository: prayerRepository,
    userRepository: userRepository,
    notificationRepository: notificationRepository,
  );
  final showAdUseCase = ShowAdUseCase(admobService: admobService);
  final assistantService = AssistantService();
  runApp(
    AppScreen(
      assistantRepository: AssistantRepositoryRemote(
        assistantService: assistantService,
      ),
      assistantService: assistantService,
      authRepository: authRepository,
      userRepository: userRepository,
      postRepository: PostRepositoryRemote(
        firestorePostService: FirestorePostService(),
      ),
      dhikrRepository: dhikrRepository,
      appRepository: appRepository,
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
      notificationRepository: notificationRepository,
      requestPermissionUseCase: requestPermissionUseCase,
      getPermissionStatesUseCase: getPermissionStatesUseCase,
      schedulePrayerNotificationsUseCase: schedulePrayerNotificationsUseCase,
      notificationService: notificationService,
      admobService: admobService,
      showAdUseCase: showAdUseCase,
      hiveDhikr: hiveDhikr,
      syncPermissionUseCase: SyncPermissionUseCase(
        getPermissionStatesUseCase: getPermissionStatesUseCase,
        requestPermissionUseCase: requestPermissionUseCase,
        appRepository: appRepository,
        notificationService: notificationService,
      ),
      wipeDataUseCase: wipeDataUseCase,
    ),
  );
}
