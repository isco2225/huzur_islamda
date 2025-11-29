import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';

class MaritalStatusSelector extends StatelessWidget {
  const MaritalStatusSelector({
    super.key,
    String? selectedStatus,
    ValueChanged<String>? onStatusChanged,
    required ValueNotifier<bool> displayError,
  }) : _selectedStatus = selectedStatus,
       _onStatusChanged = onStatusChanged,
       _displayError = displayError;

  final String? _selectedStatus;
  final ValueChanged<String>? _onStatusChanged;
  final ValueNotifier<bool> _displayError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextFieldTitle(text: 'Evlilik Durumu'),
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
                        text: 'Evli',
                        isSelected: _selectedStatus == 'Evli',
                        onTap: () {
                          _onStatusChanged?.call('Evli');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusButton(
                        text: 'Bekar',
                        isSelected: _selectedStatus == 'Bekar',
                        onTap: () {
                          _onStatusChanged?.call('Bekar');
                        },
                      ),
                    ),
                  ],
                ),
                if (displayError &&
                    (_selectedStatus == null || _selectedStatus.isEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      context.voFailureToUserFriendlyMessage(
                            MaritalStatusValueObject.dirty(
                              _selectedStatus ?? '',
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
