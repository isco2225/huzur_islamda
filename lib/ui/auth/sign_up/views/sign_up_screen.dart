import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/app.dart';
import '../../../../data/data.dart';
import '../../../../domain/consumer/use_cases/use_cases.dart';
import '../../../ui.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final SignUpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // ViewModel'i oluştur
    _viewModel = SignUpViewModel(
      signUpUseCase: SignUpUseCase(
        authRepository: context.read<AuthRepository>(),
        userRepository: context.read<UserRepository>(),
      ),
      checkEmailVerificationUseCase: CheckEmailVerificationUseCase(
        authRepository: context.read<AuthRepository>(),
        userRepository: context.read<UserRepository>(),
      ),
      authRepository: context.read<AuthRepository>(),
    );

    // Error handling
    _viewModel.requestSignUp.handleError(context, showSnackBar: true);

    // Success handling
    _viewModel.requestSignUp.handleCompleted(
      context,
      successMessage: 'Kayıt başarılı! Email doğrulama linki gönderildi.',
      onCompleted: (consumer) {
        const EmailVerificationRoute().go(context);
      },
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignUpView(viewModel: _viewModel);
  }
}
