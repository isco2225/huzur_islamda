import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class UserProfileSurnameTextField extends StatelessWidget {
  const UserProfileSurnameTextField({
    super.key,
    required TextEditingController surname,
    required ValueNotifier<bool> displayError,
  }) : _surname = surname,
       _displayError = displayError;

  final TextEditingController _surname;
  final ValueNotifier<bool> _displayError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Soyisim'),
        ValueListenableBuilder<bool>(
          valueListenable: _displayError,
          builder: (context, displayError, _) {
            return AppTextField(
              '',
              hideText: '',
              showText: '',

              textEditingController: _surname,
              textCapitalization: TextCapitalization.words,
              errorText: displayError
                  ? context.voFailureToUserFriendlyMessage(
                      SurnameValueObject.dirty(_surname.text.trim()).error,
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }
}
