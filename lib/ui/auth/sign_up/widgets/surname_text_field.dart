import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class SurnameTextField extends StatelessWidget {
  const SurnameTextField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Soyisim'),
        AppTextField(
          'Soyisim',
          hideText: '',
          showText: '',
          textEditingController: controller,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
