import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/data.dart';
import '../../../ui.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final ChangePasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ChangePasswordViewModel(
      authRepository: context.read<AuthRepository>(),
    );

    _viewModel.changePassword.handleError(context, showSnackBar: true);
    _viewModel.changePassword.handleCompleted(
      context,
      successMessage: 'Şifreniz başarıyla güncellendi.',
      popCount: 1,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangePasswordView(viewModel: _viewModel);
  }
}
