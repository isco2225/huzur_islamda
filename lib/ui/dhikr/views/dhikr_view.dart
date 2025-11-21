import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class DhikrView extends StatelessWidget {
  const DhikrView({super.key, required this.viewModel});

  final DhikrViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Text('Dhikr', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
