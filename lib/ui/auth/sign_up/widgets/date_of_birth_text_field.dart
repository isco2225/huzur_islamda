import 'package:flutter/material.dart';

import '../../../../app/app.dart';

class DateOfBirthTextField extends StatelessWidget {
  const DateOfBirthTextField({super.key, this.controller, this.onTap});

  final TextEditingController? controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Doğum Tarihi'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextFormField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade300,
              labelText: 'GG/AA/YYYY',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              suffixIcon: const Icon(Icons.calendar_today, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
