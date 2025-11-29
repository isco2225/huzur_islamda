import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class SignInEmailTextField extends StatelessWidget {
  const SignInEmailTextField({
    super.key,
    required TextEditingController email,
    required ValueNotifier<bool> displayError,
  }) : _email = email,
       _displayError = displayError;

  final TextEditingController _email;
  final ValueNotifier<bool> _displayError;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Email'),
        AppTextField(
          'Email',
          hideText: '',
          showText: '',
          textEditingController: _email,
          keyboardType: TextInputType.emailAddress,
          errorText: _displayError.value
              ? context.voFailureToUserFriendlyMessage(
                  Email.dirty(_email.text).error,
                )
              : null,
        ),
      ],
    );
  }
}
