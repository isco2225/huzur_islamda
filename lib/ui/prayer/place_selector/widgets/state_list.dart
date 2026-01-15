import 'package:flutter/material.dart';

import '../../../ui.dart';

class StateList extends StatelessWidget {
  const StateList({
    super.key,
    required this.placeSelectorViewModel,
    required this.onTapClearSearchQuery,
  });
  final PlaceSelectorViewModel placeSelectorViewModel;
  final VoidCallback onTapClearSearchQuery;

  @override
  Widget build(BuildContext context) {
    final stateSelector = placeSelectorViewModel.stateSelector;

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
                            final stateId = filteredStates[index].id;
                            stateSelector.selectState.execute(stateId);
                            onTapClearSearchQuery();
                          },
                        ),
                      ),
              );
      },
    );
  }
}
