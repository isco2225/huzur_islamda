import 'package:flutter/material.dart';

import '../../ui.dart';

class PlaceSelector extends StatefulWidget {
  const PlaceSelector({
    super.key,
    required this.viewModel,
    required this.onCountryIdSelected,
  });
  final PrayerViewModel viewModel;
  final Function(String) onCountryIdSelected;

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ülke Seçin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Search TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchQueryController,
                onChanged: (value) =>
                    widget.viewModel.searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Ülke ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ValueListenableBuilder<String>(
                    valueListenable: widget.viewModel.searchQuery,
                    builder: (context, query, child) {
                      if (query.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.viewModel.searchQuery.value = '';
                          // clear input field
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
              child: ValueListenableBuilder(
                valueListenable: widget.viewModel.getCountries.running,
                builder: (context, running, _) {
                  return running
                      ? const Center(child: CircularProgressIndicator())
                      : ValueListenableBuilder(
                          valueListenable: widget.viewModel.filteredCountries,
                          builder: (context, filteredCountries, _) =>
                              filteredCountries.isEmpty
                              ? const Center(child: Text('No countries found'))
                              : ListView.builder(
                                  itemCount: filteredCountries.length,
                                  itemBuilder: (context, index) => ListTile(
                                    title: Text(filteredCountries[index].name),
                                    onTap: () {
                                      widget.onCountryIdSelected(
                                        filteredCountries[index].id,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
