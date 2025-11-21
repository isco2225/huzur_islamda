import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key, required this.viewModel});

  final SearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Text(
          'Search',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
