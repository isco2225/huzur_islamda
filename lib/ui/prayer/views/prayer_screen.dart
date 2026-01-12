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
  late final PlaceSelectorViewModel _placeSelectorViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PrayerViewModel();
    _placeSelectorViewModel = PlaceSelectorViewModel(
      placesRepository: context.read<PlacesRepository>(),
    );
    _placeSelectorViewModel.getCountries.handleError(
      context,
      showSnackBar: true,
    );
    _placeSelectorViewModel.getCountries.handleCompleted(
      context,
      successMessage: 'Countries fetched successfully',
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _placeSelectorViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerView(
      viewModel: _viewModel,
      placeSelectorViewModel: _placeSelectorViewModel,
    );
  }
}
