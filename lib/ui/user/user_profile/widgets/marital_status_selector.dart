import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    super.key,
    String? selectedGender,
    ValueChanged<String>? onGenderChanged,
    required ValueNotifier<bool> displayError,
  }) : _selectedGender = selectedGender,
       _onGenderChanged = onGenderChanged,
       _displayError = displayError;

  final String? _selectedGender;
  final ValueChanged<String>? _onGenderChanged;
  final ValueNotifier<bool> _displayError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Cinsiyet'),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _displayError,
          builder: (context, displayError, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatusButton(
                        text: 'Erkek',
                        isSelected: _selectedGender == 'Erkek',
                        onTap: () {
                          _onGenderChanged?.call('Erkek');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusButton(
                        text: 'Kadın',
                        isSelected: _selectedGender == 'Kadın',
                        onTap: () {
                          _onGenderChanged?.call('Kadın');
                        },
                      ),
                    ),
                  ],
                ),
                if (displayError &&
                    (_selectedGender == null || _selectedGender.isEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      context.voFailureToUserFriendlyMessage(
                            GenderValueObject.dirty(
                              _selectedGender ?? '',
                            ).error,
                          ) ??
                          '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
