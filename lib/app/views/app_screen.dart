import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../app.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.postRepository,
    required this.dhikrRepository,
    required this.dhikrUseCase,
    required this.placesRepository,
    required this.appRepository,
    required this.connectivityUseCase,
    required this.prayerRepository,
    required this.prayerTimeUseCase,
    required this.notificationRepository,
    required this.requestPermissionUseCase,
    required this.getPermissionStatesUseCase,
    required this.schedulePrayerNotificationsUseCase,
    required this.notificationService,
    required this.admobService,
    required this.showAdUseCase,
    required this.hiveDhikr,
    required this.syncPermissionUseCase,
    required this.wipeDataUseCase,
  });
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final DhikrRepository dhikrRepository;
  final AppRepository appRepository;
  final DhikrUseCase dhikrUseCase;
  final PlacesRepository placesRepository;
  final ConnectivityUseCase connectivityUseCase;
  final PrayerRepository prayerRepository;
  final PrayerTimeUseCase prayerTimeUseCase;
  final NotificationRepository notificationRepository;
  final RequestPermissionUseCase requestPermissionUseCase;
  final GetPermissionStatesUseCase getPermissionStatesUseCase;
  final SchedulePrayerNotificationsUseCase schedulePrayerNotificationsUseCase;
  final NotificationService notificationService;
  final AdMobService admobService;
  final ShowAdUseCase showAdUseCase;
  final HiveService hiveDhikr;
  final SyncPermissionUseCase syncPermissionUseCase;
  final WipeDataUseCase wipeDataUseCase;
  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  late final AppViewModel _appViewModel;

  @override
  void initState() {
    super.initState();
    _appViewModel = AppViewModel(
      appRepository: widget.appRepository,
      authRepository: widget.authRepository,
      userRepository: widget.userRepository,
      hiveRepository: HiveRepositoryRemote(
        hiveInitializer: HiveInitializerService(),
        hiveService: widget.hiveDhikr,
      ),
      dhikrUseCase: widget.dhikrUseCase,
      prayerTimeUseCase: widget.prayerTimeUseCase,
      syncPermissionUseCase: widget.syncPermissionUseCase,
      wipeDataUseCase: widget.wipeDataUseCase,
      schedulePrayerNotificationsUseCase:
          widget.schedulePrayerNotificationsUseCase,
    );
    // App'i başlat
    _appViewModel.initApp.execute();
    _appViewModel.initUser.execute();
  }

  @override
  void dispose() {
    _appViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // repositories
        Provider(
          create: (_) => CreateUserProfileUseCase(
            authRepository: widget.authRepository,
            userRepository: widget.userRepository,
          ),
        ),
        Provider(create: (_) => widget.authRepository),
        Provider(create: (_) => widget.userRepository),
        Provider(create: (_) => widget.appRepository),
        Provider(create: (_) => widget.postRepository),
        Provider(create: (_) => widget.dhikrRepository),
        Provider(create: (_) => widget.placesRepository),
        Provider(create: (_) => widget.prayerRepository),
        Provider(create: (_) => widget.notificationRepository),
        Provider(create: (_) => widget.notificationService),
        Provider(create: (_) => widget.admobService),

        // use cases
        Provider(create: (_) => widget.dhikrUseCase),
        Provider(create: (_) => widget.prayerTimeUseCase),
        Provider(create: (_) => widget.connectivityUseCase, lazy: true),
        Provider(create: (_) => widget.requestPermissionUseCase),
        Provider(create: (_) => widget.getPermissionStatesUseCase),
        Provider(create: (_) => widget.schedulePrayerNotificationsUseCase),
        Provider(create: (_) => widget.syncPermissionUseCase),
        Provider(create: (_) => widget.wipeDataUseCase),
        Provider(create: (_) => widget.showAdUseCase),
      ],
      child: ValueListenableBuilder(
        valueListenable: _appViewModel.initApp.running,
        builder: (context, isInitializing, child) {
          // App initialization tamamlanana kadar splash screen göster
          if (isInitializing) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(body: Center(child: AppSplashView())),
            );
          }
          // Initialization tamamlandı, router'ı göster
          // Router'ın tüm state değişikliklerini dinlemesi için
          // auth, user ve appPreferences state'lerini birleştiriyoruz
          return AppView(
            refreshListenable: Listenable.merge([
              widget.authRepository.auth,
              widget.userRepository.currentUser,
              widget.appRepository.appPreferences,
            ]),
          );
        },
      ),
    );
  }
}
