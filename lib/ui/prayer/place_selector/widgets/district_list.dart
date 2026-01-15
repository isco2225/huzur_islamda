import 'package:flutter/material.dart';

import '../../../ui.dart';

class DistrictList extends StatelessWidget {
  const DistrictList({
    super.key,
    required this.placeSelectorViewModel,
    required this.onTapClearSearchQuery,
  });
  final PlaceSelectorViewModel placeSelectorViewModel;
  final VoidCallback onTapClearSearchQuery;

  @override
  Widget build(BuildContext context) {
    final districtSelector = placeSelectorViewModel.districtSelector;

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
                            final districtId = filteredDistricts[index].id;
                            districtSelector.selectDistrict.execute(districtId);
                          },
                        ),
                      ),
              );
      },
    );
  }
}
