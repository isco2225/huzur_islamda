import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/data.dart';
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
      authRepository: context.read<AuthRepository>(),
    );

    // Error handling
    _viewModel.requestSignUp.handleError(context, showSnackBar: true);

    // Success handling
    _viewModel.requestSignUp.handleCompleted(
      context,
      successMessage: 'Kayıt başarılı! Email doğrulama linki gönderildi.',
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
