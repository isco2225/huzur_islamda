import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';

class PlaceSelector extends StatefulWidget {
  const PlaceSelector({
    super.key,
    required this.viewModel,
    required this.editProfileViewModel,
  });
  final PlaceSelectorViewModel viewModel;
  final EditProfileViewModel editProfileViewModel;
  @override
  State<PlaceSelector> createState() => _PlaceSelectorState();
}

class _PlaceSelectorState extends State<PlaceSelector> {
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  void dispose() {
    _searchQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 400,
        child: ValueListenableBuilder<PlaceSelectionMode>(
          valueListenable: widget.viewModel.selectionMode,
          builder: (context, selectionMode, _) {
            final isSelectingCountry =
                selectionMode == PlaceSelectionMode.country;
            // Get current search query based on selection mode
            final currentSearchQuery = switch (selectionMode) {
              PlaceSelectionMode.country =>
                widget.viewModel.countrySelector.searchQuery,
              PlaceSelectionMode.state =>
                widget.viewModel.stateSelector.searchQuery,
              PlaceSelectionMode.district =>
                widget.viewModel.districtSelector.searchQuery,
            };
            // Get title based on selection mode
            final title = switch (selectionMode) {
              PlaceSelectionMode.country => 'Ülke Seçin',
              PlaceSelectionMode.state => 'Şehir Seçin',
              PlaceSelectionMode.district => 'İlçe Seçin',
            };
            // Get hint text based on selection mode
            final hintText = switch (selectionMode) {
              PlaceSelectionMode.country => 'Ülke ara...',
              PlaceSelectionMode.state => 'Şehir ara...',
              PlaceSelectionMode.district => 'İlçe ara...',
            };
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!isSelectingCountry)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            widget.viewModel.goBack();
                            _searchQueryController.clear();
                          },
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: isSelectingCountry
                              ? TextAlign.center
                              : TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchQueryController,
                    onChanged: (value) => currentSearchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: ValueListenableBuilder(
                        valueListenable: currentSearchQuery,
                        builder: (context, query, _) {
                          if (query.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              currentSearchQuery.value = '';
                              _searchQueryController.clear();
                            },
                          );
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: switch (selectionMode) {
                    PlaceSelectionMode.country => CountryList(
                      placeSelectorViewModel: widget.viewModel,
                      onTapClearSearchQuery: () =>
                          _searchQueryController.clear(),
                    ),
                    PlaceSelectionMode.state => StateList(
                      placeSelectorViewModel: widget.viewModel,
                      onTapClearSearchQuery: () =>
                          _searchQueryController.clear(),
                    ),
                    PlaceSelectionMode.district => DistrictList(
                      placeSelectorViewModel: widget.viewModel,
                      onTapClearSearchQuery: () =>
                          _searchQueryController.clear(),
                    ),
                  },
                ),
                if (selectionMode == PlaceSelectionMode.district)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ValueListenableBuilder<String?>(
                      valueListenable:
                          widget.viewModel.districtSelector.selectedDistrictId,
                      builder: (context, selectedDistrictId, _) {
                        if (selectedDistrictId == null) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: 'Vakitleri Getir',
                            onPressed: () async {
                              await widget
                                  .editProfileViewModel
                                  .updateUserLocation
                                  .execute((
                                    country: widget.viewModel.countrySelector
                                        .getSelectedCountryName(),
                                    city: widget.viewModel.stateSelector
                                        .getSelectedStateName(),
                                    districtId: selectedDistrictId,
                                  ));
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            running: widget
                                .editProfileViewModel
                                .updateUserLocation
                                .running,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
