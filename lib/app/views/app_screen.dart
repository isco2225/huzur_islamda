import 'package:flutter/material.dart';
import 'package:huzur_islamda/domain/user/use_cases/create_user_profile_use_case.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../app.dart';
import '../view_models/app_view_model.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.postRepository,
  });
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PostRepository postRepository;
  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  late final AppViewModel _appViewModel;

  @override
  void initState() {
    super.initState();
    _appViewModel = AppViewModel(
      authRepository: widget.authRepository,
      userRepository: widget.userRepository,
    );
    // App'i başlat
    _appViewModel.initApp.execute();
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
        Provider(
          create: (_) => CreateUserProfileUseCase(
            authRepository: widget.authRepository,
            userRepository: widget.userRepository,
          ),
        ),
        Provider(create: (_) => widget.authRepository),
        Provider(create: (_) => widget.userRepository),
        Provider(create: (_) => widget.postRepository),
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
