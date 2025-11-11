import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class SurnameTextField extends StatelessWidget {
  const SurnameTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(text: 'Soyisim'),
        AppTextField('Soyisim', hideText: '', showText: ''),
      ],
    );
  }
}
