import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class DhikrView extends StatelessWidget {
  const DhikrView({super.key, required this.viewModel});

  final FetchDhikrsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final selectedDate = viewModel.selectedDate.value;
    return BaseScaffold(
      safeArea: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushCreateDhikr();
        },
        heroTag: 'create_dhikr',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(title: const Text('Zikirlerim')),
      body: Column(
        children: [
          DhikrDateSelector(viewModel: viewModel),
          Expanded(
            child: InfinityScrollableDhikrs(
              fetchDhikrsViewModel: viewModel,
              noItemsToShowWidget: selectedDate == DateTime.now()
                  ? const Center(child: NoDhikrsToShow())
                  : const Center(
                      child: Text(
                        'Bu tarih için zikir yok.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
              onFetch: () {
                viewModel.fetchDhikrs.execute(selectedDate);
              },
              dhikrs: viewModel.dhikrs,
              hasError: viewModel.fetchDhikrs.error,
              isFetching: viewModel.fetchDhikrs.running,
              isAllItemsFetched: viewModel.fetchDhikrs.completed,
            ),
          ),
        ],
      ),
    );
  }
}
