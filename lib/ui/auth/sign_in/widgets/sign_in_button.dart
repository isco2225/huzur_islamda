import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({
    required this.viewModel,
    required this.email,
    required this.password,
    required this.displayEmailVOError,
    required this.displayPasswordVOError,
    super.key,
  });
  final SignInViewModel viewModel;
  final TextEditingController email;
  final TextEditingController password;
  final ValueNotifier<bool> displayEmailVOError;
  final ValueNotifier<bool> displayPasswordVOError;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Giriş Yap',
      onPressed: () {
        if (!_isValueObjectsValid()) return;
        viewModel.signIn.execute((
          email: email.text.trim(),
          password: password.text,
        ));
      },
      running: viewModel.signIn.running,
    );
  }

  bool _isValueObjectsValid() {
    final isEmailValid = Email.dirty(email.text.trim()).isValid;
    final isPasswordValid = Password.dirty(password.text).isValid;
    displayEmailVOError.value = !isEmailValid;
    displayPasswordVOError.value = !isPasswordValid;
    return isPasswordValid && isEmailValid;
  }
}
