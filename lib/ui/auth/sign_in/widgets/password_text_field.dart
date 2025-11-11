import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class PasswordTextField extends StatelessWidget {
  const PasswordTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextFieldTitle(text: 'Şifre'),
            Text('Şifremi Unuttum?'),
          ],
        ),
        AppTextField(
          'Şifre',
          hideText: 'gizle',
          showText: 'göster',
          isPassword: true,
        ),
      ],
    );
  }
}
