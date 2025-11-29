import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class SignUpEmailTextField extends StatelessWidget {
  const SignUpEmailTextField({
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
          showText: 'göster',
          hideText: 'gizle',
          keyboardType: TextInputType.emailAddress,
          errorText: _displayError.value
              ? context.voFailureToUserFriendlyMessage(
                  Email.dirty(_email.text).error,
                )
              : null,
          textEditingController: _email,
        ),
      ],
    );
  }
}
