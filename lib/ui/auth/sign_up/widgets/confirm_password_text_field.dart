import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  const ConfirmPasswordTextField({
    super.key,
    required TextEditingController confirmPassword,
    required ValueNotifier<bool> displayError,
    required TextEditingController password,
  }) : _confirmPassword = confirmPassword,
       _displayError = displayError,
       _password = password;
  final TextEditingController _confirmPassword;
  final ValueNotifier<bool> _displayError;
  final TextEditingController _password;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Şifre Tekrarı'),
        AppTextField(
          'Şifre Tekrarı',
          hideText: 'gizle',
          showText: 'göster',
          isPassword: true,
          textEditingController: _confirmPassword,
          errorText: _displayError.value
              ? context.voFailureToUserFriendlyMessage(
                  ConfirmPassword.dirty(
                    password: _password.text,
                    value: _confirmPassword.text,
                  ).error,
                )
              : null,
        ),
      ],
    );
  }
}
