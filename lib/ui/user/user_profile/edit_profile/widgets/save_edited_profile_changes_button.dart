import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huzur_islamda/app/app.dart';

import '../../../../../domain/domain.dart';
import '../../../../ui.dart';

class SaveEditedProfileChangesButton extends StatelessWidget {
  const SaveEditedProfileChangesButton({
    super.key,
    required this.viewModel,
    required this.running,
    required this.displayNameError,
    required this.displaySurnameError,
    required this.displayDateOfBirthError,
    required this.displayGenderError,
    required this.nameController,
    required this.surnameController,
    required this.dateOfBirthController,
    required this.selectedGender,
  });

  final EditProfileViewModel viewModel;
  final ValueListenable<bool> running;
  final ValueNotifier<bool> displayNameError;
  final ValueNotifier<bool> displaySurnameError;
  final ValueNotifier<bool> displayDateOfBirthError;
  final ValueNotifier<bool> displayGenderError;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController dateOfBirthController;
  final String selectedGender;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.isSmallScreen ? 48 : 52,
      child: AppButton(
        onPressed: () {
          if (!_isValueObjectsValid()) return;
          viewModel.updateProfile.execute((
            name: nameController.text.trim(),
            surname: surnameController.text.trim(),
            dateOfBirth: dateOfBirthController.text,
            gender: selectedGender,
          ));
        },
        text: 'Değişiklikleri Kaydet',
        running: running,
      ),
    );
  }

  bool _isValueObjectsValid() {
    final isNameValid = NameValueObject.dirty(
      nameController.text.trim(),
    ).isValid;
    final isSurnameValid = SurnameValueObject.dirty(
      surnameController.text.trim(),
    ).isValid;
    final isDateOfBirthValid = DateOfBirthValueObject.dirty(
      dateOfBirthController.text,
    ).isValid;
    final isGenderValid = GenderValueObject.dirty(selectedGender).isValid;

    displayNameError.value = !isNameValid;
    displaySurnameError.value = !isSurnameValid;
    displayDateOfBirthError.value = !isDateOfBirthValid;
    displayGenderError.value = !isGenderValid;

    return isNameValid && isSurnameValid && isDateOfBirthValid && isGenderValid;
  }
}
