import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
import '../../../ui.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final SignInViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignInViewModel(
      authRepository: context.read<AuthRepository>(),
      userRepository: context.read<UserRepository>(),
    );

    // Error handling
    _viewModel.signIn.handleError(context, showSnackBar: true);

    // Success handling
    _viewModel.signIn.handleCompleted(
      context,
      successMessage: 'Giriş başarılı!',
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignInView(viewModel: _viewModel);
  }
}
