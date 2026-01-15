import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../ui.dart';
import '../view_models/prayer_times_view_model.dart';

class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key, required this.viewModel});

  final PrayerTimesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      appBar: AppBar(
        title: const Text('Namaz Vakitleri'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      safeArea: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.verticalPadding,
          ),
          child: Column(
            children: [
              // TODO: Add prayer times UI here
              const Text('Prayer Times View'),
            ],
          ),
        ),
      ),
    );
  }
}
