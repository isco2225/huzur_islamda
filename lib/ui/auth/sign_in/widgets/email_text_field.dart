import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(text: 'Email'),
        AppTextField('Email', hideText: 'gizle', showText: 'göster'),
      ],
    );
  }
}
