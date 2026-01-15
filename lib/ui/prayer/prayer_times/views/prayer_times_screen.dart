import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/domain.dart';
import '../view_models/prayer_times_view_model.dart';
import 'prayer_times_view.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  late final PrayerTimesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PrayerTimesViewModel(
      prayerTimeUseCase: context.read<PrayerTimeUseCase>(),
    );

    // TODO: Set up error handlers
    // _viewModel.someCommand.handleError(context);
    // _viewModel.someCommand.handleCompleted(context);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerTimesView(viewModel: _viewModel);
  }
}
