import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    this.controller,
    this.showForgotPassword = true,
  });

  final TextEditingController? controller;
  final bool showForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextFieldTitle(text: 'Şifre'),
            if (showForgotPassword) const Text('Şifremi Unuttum?'),
          ],
        ),
        AppTextField(
          'Şifre',
          hideText: 'gizle',
          showText: 'göster',
          isPassword: true,
          textEditingController: controller,
        ),
      ],
    );
  }
}
