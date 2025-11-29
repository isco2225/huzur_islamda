import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class SignInPasswordTextField extends StatelessWidget {
  const SignInPasswordTextField({
    super.key,
    required TextEditingController password,
    required ValueNotifier<bool> displayError,
  }) : _password = password,
       _displayError = displayError;

  final TextEditingController _password;
  final ValueNotifier<bool> _displayError;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Şifre'),
        AppTextField(
          'Şifre',
          hideText: 'gizle',
          showText: 'göster',
          isPassword: true,
          textEditingController: _password,
          errorText: _displayError.value
              ? context.voFailureToUserFriendlyMessage(
                  Password.dirty(_password.text).error,
                )
              : null,
        ),
      ],
    );
  }
}
