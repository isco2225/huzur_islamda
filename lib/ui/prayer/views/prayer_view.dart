import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key, required this.viewModel});

  final PrayerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      body: Center(
        child: Text(
          'Prayer',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
