import 'package:flutter/material.dart';

import '../../../ui.dart';

class PlaceSelector extends StatefulWidget {
  const PlaceSelector({
    super.key,
    required this.viewModel,
    required this.onCountryIdSelected,
    this.onStateIdSelected,
  });
  final PlaceSelectorViewModel viewModel;
  final Function(String) onCountryIdSelected;
  final Function(String)? onStateIdSelected;

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
            final currentSearchQuery = isSelectingCountry
                ? widget.viewModel.countrySelector.searchQuery
                : widget.viewModel.stateSelector.searchQuery;

            return Column(
              children: [
                // Header with back button (if selecting state)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      if (!isSelectingCountry)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            // Ülkelere geri dön
                            widget.viewModel.backToCountrySelection();
                            _searchQueryController.clear();
                          },
                        ),
                      Expanded(
                        child: Text(
                          isSelectingCountry ? 'Ülke Seçin' : 'Şehir Seçin',
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
                      hintText: isSelectingCountry
                          ? 'Ülke ara...'
                          : 'Şehir ara...',
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
                // List: Countries OR States
                Expanded(
                  child: isSelectingCountry
                      ? _buildCountryList()
                      : _buildStateList(),
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
                          onTap: () {
                            // Şehir seçildi
                            final stateId = filteredStates[index].id;
                            stateSelector.selectState.execute(stateId);
                            widget.onStateIdSelected?.call(stateId);
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
