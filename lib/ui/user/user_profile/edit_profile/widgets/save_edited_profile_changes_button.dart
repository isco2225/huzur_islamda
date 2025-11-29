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
    required this.displayMaritalStatusError,
    required this.nameController,
    required this.surnameController,
    required this.dateOfBirthController,
    required this.selectedMaritalStatus,
  });

  final EditProfileViewModel viewModel;
  final ValueListenable<bool> running;
  final ValueNotifier<bool> displayNameError;
  final ValueNotifier<bool> displaySurnameError;
  final ValueNotifier<bool> displayMaritalStatusError;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController dateOfBirthController;
  final String selectedMaritalStatus;

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
            maritalStatus: selectedMaritalStatus,
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
    final isMaritalStatusValid = MaritalStatusValueObject.dirty(
      selectedMaritalStatus,
    ).isValid;

    displayNameError.value = !isNameValid;
    displaySurnameError.value = !isSurnameValid;
    displayMaritalStatusError.value = !isMaritalStatusValid;

    return isNameValid &&
        isSurnameValid &&
        isDateOfBirthValid &&
        isMaritalStatusValid;
  }
}
