import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class SignUpPasswordTextField extends StatelessWidget {
  const SignUpPasswordTextField({
    super.key,
    required TextEditingController password,
    required ValueNotifier<bool> displayError,
    this.focusNode,
    this.onPasswordSubmitted,
  }) : _password = password,
       _displayError = displayError;
  final TextEditingController _password;
  final ValueNotifier<bool> _displayError;
  final FocusNode? focusNode;
  final void Function(String)? onPasswordSubmitted;
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
          focusNode: focusNode,
          onSubmitted: onPasswordSubmitted,
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
