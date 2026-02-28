import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class DateOfBirthTextField extends StatelessWidget {
  const DateOfBirthTextField({
    super.key,
    this.controller,
    this.onTap,
    this.displayError,
  });

  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueNotifier<bool>? displayError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(text: 'Doğum Tarihi (Opsiyonel)'),
        _buildTextField(context),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    if (displayError != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: displayError!,
        builder: (context, displayErrorValue, _) {
          return Padding(
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
                errorText: displayErrorValue && controller != null
                    ? context.voFailureToUserFriendlyMessage(
                        DateOfBirthValueObject.dirty(controller!.text).error,
                      )
                    : null,
              ),
            ),
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade300,
          labelText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
      ),
    );
  }
}
