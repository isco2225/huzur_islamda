import 'package:flutter/material.dart';

import '../../../ui.dart';

class CountryList extends StatelessWidget {
  const CountryList({
    super.key,
    required this.placeSelectorViewModel,
    required this.onTapClearSearchQuery,
  });
  final PlaceSelectorViewModel placeSelectorViewModel;
  final VoidCallback onTapClearSearchQuery;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:
          placeSelectorViewModel.countrySelector.getCountries.running,
      builder: (context, running, _) {
        return running
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder(
                valueListenable:
                    placeSelectorViewModel.countrySelector.filteredCountries,
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
                            final countryId = filteredCountries[index].id;
                            placeSelectorViewModel.countrySelector.selectCountry
                                .execute(countryId);
                            onTapClearSearchQuery();
                          },
                        ),
                      ),
              );
      },
    );
  }
}
