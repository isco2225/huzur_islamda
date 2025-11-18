import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class NameTextField extends StatelessWidget {
  const NameTextField({
    super.key,
    this.controller,
  });

  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'İsim'),
        AppTextField(
          'İsim',
          hideText: '',
          showText: '',
          textEditingController: controller,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}
