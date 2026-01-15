import 'package:flutter/material.dart';

import '../../ui.dart';

class PlaceSelectorButton extends StatelessWidget {
  const PlaceSelectorButton({
    super.key,
    required this.placeSelectorViewModel,
    required this.editProfileViewModel,
  });

  final PlaceSelectorViewModel placeSelectorViewModel;
  final EditProfileViewModel editProfileViewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable:
          placeSelectorViewModel.countrySelector.getCountries.running,
      builder: (context, isLoading, child) {
        return TextButton(
          onPressed: isLoading
              ? null
              : () {
                  placeSelectorViewModel.countrySelector.getCountries.execute();
                  showDialog<void>(
                    context: context,
                    builder: (context) => PlaceSelector(
                      viewModel: placeSelectorViewModel,
                      editProfileViewModel: editProfileViewModel,
                    ),
                  );
                },
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Yer Seçin'),
        );
      },
    );
  }
}
