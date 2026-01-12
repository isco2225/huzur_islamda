import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../app.dart';
import '../view_models/app_view_model.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.postRepository,
    required this.dhikrRepository,
    required this.placesRepository,
  });
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final DhikrRepository dhikrRepository;
  final PlacesRepository placesRepository;
  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with WidgetsBindingObserver {
  late final AppViewModel _appViewModel;

  @override
  void initState() {
    super.initState();
    _appViewModel = AppViewModel(
      authRepository: widget.authRepository,
      userRepository: widget.userRepository,
      hiveRepository: HiveRepositoryRemote(
        hiveService: HiveService<Dhikr>(Dhikr.boxName),
      ),
    );
    WidgetsBinding.instance.addObserver(this);
    // App'i başlat
    _appViewModel.initApp.execute();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // Uygulama tamamen kapanıyor - tüm Hive box'larını kapat
      Hive.close();
    }
  }

  @override
  void dispose() {
    _appViewModel.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => CreateUserProfileUseCase(
            authRepository: widget.authRepository,
            userRepository: widget.userRepository,
          ),
        ),
        Provider(create: (_) => widget.authRepository),
        Provider(create: (_) => widget.userRepository),
        Provider(create: (_) => widget.postRepository),
        Provider(create: (_) => widget.dhikrRepository),
        Provider(create: (_) => widget.placesRepository),
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
          return AppView(refreshListenable: widget.authRepository.auth);
        },
      ),
    );
  }
}
