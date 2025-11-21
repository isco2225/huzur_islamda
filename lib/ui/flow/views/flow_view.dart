import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class FlowView extends StatelessWidget {
  const FlowView({super.key, required this.viewModel});

  final FlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Text('Flow', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
