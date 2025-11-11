import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class NameTextField extends StatelessWidget {
  const NameTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(text: 'İsim'),
        AppTextField('İsim', hideText: '', showText: ''),
      ],
    );
  }
}
