import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../ui.dart';

class PrayerPopMenuButton extends StatelessWidget {
  const PrayerPopMenuButton({
    super.key,
    required this.placeSelectorViewModel,
    required this.editProfileViewModel,
  });
  final PlaceSelectorViewModel placeSelectorViewModel;
  final EditProfileViewModel editProfileViewModel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: responsive.isSmallScreen ? 20.0 : 24.0),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'place_selector',
          onTap: () {
            placeSelectorViewModel.countrySelector.getCountries.execute();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                showDialog<void>(
                  context: context,
                  builder: (context) => PlaceSelector(
                    viewModel: placeSelectorViewModel,
                    editProfileViewModel: editProfileViewModel,
                  ),
                );
              }
            });
          },
          child: Row(
            spacing: 8,
            children: [Icon(Icons.location_on, size: 20), Text('Konum Seç')],
          ),
        ),
      ],
    );
  }
}
