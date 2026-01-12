import 'package:flutter/material.dart';

import '../../../ui.dart';

class PlaceSelector extends StatefulWidget {
  const PlaceSelector({
    super.key,
    required this.viewModel,
    required this.onCountryIdSelected,
    this.onStateIdSelected,
    this.onDistrictIdSelected,
  });
  final PlaceSelectorViewModel viewModel;
  final Function(String) onCountryIdSelected;
  final Function(String)? onStateIdSelected;
  final Function(String)? onDistrictIdSelected;

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
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!isSelectingCountry)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            // Bir önceki adıma dön ama dönerken
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
                      suffixIcon: ValueListenableBuilder<String>(
                        valueListenable: currentSearchQuery,
                        builder: (context, query, child) {
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
                // List: Countries, States, or Districts
                Expanded(
                  child: switch (selectionMode) {
                    PlaceSelectionMode.country => _buildCountryList(),
                    PlaceSelectionMode.state => _buildStateList(),
                    PlaceSelectionMode.district => _buildDistrictList(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build country list
  Widget _buildCountryList() {
    final countrySelector = widget.viewModel.countrySelector;
    return ValueListenableBuilder(
      valueListenable: countrySelector.getCountries.running,
      builder: (context, running, _) {
        return running
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: countrySelector.filteredCountries,
                builder: (context, filteredCountries, _) =>
                    filteredCountries.isEmpty
                    ? const Center(child: Text('Ülke bulunamadı'))
                    : ListView.builder(
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(filteredCountries[index].name),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            // Ülke seçildi -> states'leri getir
                            final countryId = filteredCountries[index].id;
                            widget.onCountryIdSelected(countryId);
                            countrySelector.selectCountry.execute(countryId);
                            // Arama sorgusunu temizle
                            _searchQueryController.clear();
                          },
                        ),
                      ),
              );
      },
    );
  }

  /// Build state list
  Widget _buildStateList() {
    final stateSelector = widget.viewModel.stateSelector;
    return ValueListenableBuilder(
      valueListenable: stateSelector.getStates.running,
      builder: (context, running, _) {
        return running
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: stateSelector.filteredStates,
                builder: (context, filteredStates, _) => filteredStates.isEmpty
                    ? const Center(child: Text('Şehir bulunamadı'))
                    : ListView.builder(
                        itemCount: filteredStates.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(filteredStates[index].name),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            // Şehir seçildi -> districts'leri getir
                            final stateId = filteredStates[index].id;
                            widget.onStateIdSelected?.call(stateId);
                            stateSelector.selectState.execute(stateId);
                            // Arama sorgusunu temizle
                            _searchQueryController.clear();
                          },
                        ),
                      ),
              );
      },
    );
  }

  /// Build district list
  Widget _buildDistrictList() {
    final districtSelector = widget.viewModel.districtSelector;
    return ValueListenableBuilder(
      valueListenable: districtSelector.getDistricts.running,
      builder: (context, running, _) {
        return running
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable: districtSelector.filteredDistricts,
                builder: (context, filteredDistricts, _) =>
                    filteredDistricts.isEmpty
                    ? const Center(child: Text('İlçe bulunamadı'))
                    : ListView.builder(
                        itemCount: filteredDistricts.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(filteredDistricts[index].name),
                          onTap: () {
                            // İlçe seçildi - son adım
                            final districtId = filteredDistricts[index].id;
                            districtSelector.selectDistrict.execute(districtId);
                            widget.onDistrictIdSelected?.call(districtId);
                            // Dialog'u kapat
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
              );
      },
    );
  }
}
