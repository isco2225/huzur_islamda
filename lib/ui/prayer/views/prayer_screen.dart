import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/data.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late final PrayerTimesViewModel _prayerTimesViewModel;
  late final PlaceSelectorViewModel _placeSelectorViewModel;
  late final EditProfileViewModel _editProfileViewModel;
  late final FetchUserViewModel _fetchUserViewModel;
  late final User _user;
  @override
  void initState() {
    super.initState();
    _fetchUserViewModel = FetchUserViewModel(
      userRepository: context.read<UserRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
    _user = _fetchUserViewModel.currentUser.value;
    _prayerTimesViewModel = PrayerTimesViewModel(
      prayerTimeUseCase: context.read<PrayerTimeUseCase>(),
    );
    _prayerTimesViewModel.getPrayerTimes.execute((
      districtId: '',
      city: '',
      country: '',
      userId: '',
    ));
    _prayerTimesViewModel.getPrayerTimes.handleError(
      context,
      showSnackBar: true,
    );
    _prayerTimesViewModel.getPrayerTimes.handleCompleted(
      context,
      successMessage: 'Namaz vakitleri başarıyla yüklendi',
    );
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
    _prayerTimesViewModel.dispose();
    _placeSelectorViewModel.dispose();
    _editProfileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerView(
      user: _user,
      prayerTimesViewModel: _prayerTimesViewModel,
      placeSelectorViewModel: _placeSelectorViewModel,
      editProfileViewModel: _editProfileViewModel,
    );
  }
}
