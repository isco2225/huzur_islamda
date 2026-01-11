import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class SignInEmailTextField extends StatelessWidget {
  const SignInEmailTextField({
    super.key,
    required TextEditingController email,
    required ValueNotifier<bool> displayError,
    this.focusNode,
    this.onEmailSubmitted,
  }) : _email = email,
       _displayError = displayError;

  final TextEditingController _email;
  final ValueNotifier<bool> _displayError;
  final FocusNode? focusNode;
  final void Function(String)? onEmailSubmitted;
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
          focusNode: focusNode,
          textEditingController: _email,
          onSubmitted: onEmailSubmitted,
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
