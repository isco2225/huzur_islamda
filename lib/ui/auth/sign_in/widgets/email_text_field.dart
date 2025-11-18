import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({super.key, this.controller});

  final TextEditingController? controller;

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
          textEditingController: controller,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
