import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class UserProfileNameTextField extends StatelessWidget {
  const UserProfileNameTextField({
    super.key,
    required TextEditingController name,
    required ValueNotifier<bool> displayError,
  }) : _name = name,
       _displayError = displayError;

  final TextEditingController _name;
  final ValueNotifier<bool> _displayError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'İsim'),
        ValueListenableBuilder<bool>(
          valueListenable: _displayError,
          builder: (context, displayError, _) {
            return AppTextField(
              'İsim',
              hideText: '',
              showText: '',
              textEditingController: _name,
              textCapitalization: TextCapitalization.words,
              errorText: displayError
                  ? context.voFailureToUserFriendlyMessage(
                      NameValueObject.dirty(_name.text.trim()).error,
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }
}
