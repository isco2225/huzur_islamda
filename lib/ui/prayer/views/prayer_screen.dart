import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../ui.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late final PrayerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PrayerViewModel(
      countryRepository: context.read<CountryRepository>(),
    );
    _viewModel.getCountries.handleError(context, showSnackBar: true);
    _viewModel.getCountries.handleCompleted(
      context,
      successMessage: 'Countries fetched successfully',
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerView(viewModel: _viewModel);
  }
}
