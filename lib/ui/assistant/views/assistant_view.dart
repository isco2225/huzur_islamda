import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class AssistantView extends StatelessWidget {
  const AssistantView({super.key, required this.viewModel});

  final AssistantViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Text(
          'Assistant',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
