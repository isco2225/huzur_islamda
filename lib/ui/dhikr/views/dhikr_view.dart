import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class DhikrView extends StatelessWidget {
  const DhikrView({super.key, required this.viewModel});

  final FetchDhikrsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          const CreateDhikrRoute().push(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(title: const Text('Zikirlerim')),
      body: InfinityScrollableDhikrs(
        fetchDhikrsViewModel: viewModel,
        noItemsToShowWidget: Center(child: const NoDhikrsToShow()),
        onFetch: () => viewModel.fetchDhikrs.execute(),
        dhikrs: viewModel.dhikrs,
        hasError: viewModel.fetchDhikrs.error,
        isFetching: viewModel.fetchDhikrs.running,
        isAllItemsFetched: viewModel.fetchDhikrs.completed,
      ),
    );
  }
}
