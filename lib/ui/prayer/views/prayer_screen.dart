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
  late final EditProfileViewModel _editProfileViewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = PrayerViewModel();
    _placeSelectorViewModel = PlaceSelectorViewModel(
      placesRepository: context.read<PlacesRepository>(),
    );
    _editProfileViewModel = EditProfileViewModel(
      userRepository: context.read<UserRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
    _placeSelectorViewModel.countrySelector.getCountries.handleError(
      context,
      showSnackBar: true,
    );
    _placeSelectorViewModel.countrySelector.getCountries.handleCompleted(
      context,
      successMessage: 'Ülkeler başarıyla yüklendi',
    );
    _editProfileViewModel.updateUserLocation.handleError(
      context,
      showSnackBar: true,
    );
    _editProfileViewModel.updateUserLocation.handleCompleted(
      context,
      successMessage: 'Konum başarıyla güncellendi!',
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _placeSelectorViewModel.dispose();
    _editProfileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerView(
      viewModel: _viewModel,
      placeSelectorViewModel: _placeSelectorViewModel,
      editProfileViewModel: _editProfileViewModel,
    );
  }
}
