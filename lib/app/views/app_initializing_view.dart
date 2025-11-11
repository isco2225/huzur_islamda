import 'package:flutter/material.dart';

import '../app.dart';

class AppInitializingView extends StatelessWidget {
  const AppInitializingView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      home: Center(child: const AppSplashView()),
    );
  }
}
