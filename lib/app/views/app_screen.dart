import 'package:flutter/material.dart';
import 'package:huzur_islamda/domain/consumer/use_cases/check_email_verification_use_case.dart';
import 'package:provider/provider.dart';
import '../../data/data.dart';
import '../app.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({
    super.key,
    required this.authRepository,
    required this.userRepository,
  });
  final AuthRepository authRepository;
  final UserRepository userRepository;
  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => CheckEmailVerificationUseCase(
            authRepository: widget.authRepository,
            userRepository: widget.userRepository,
          ),
        ),
        Provider(create: (_) => widget.authRepository),
        Provider(create: (_) => widget.userRepository),
      ],
      child: AppView(),
    );
  }
}
