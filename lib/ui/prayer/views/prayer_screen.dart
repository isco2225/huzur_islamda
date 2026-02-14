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
  late final PrayerViewModel _prayerViewModel;
  late final AdvertViewModel _advertViewModel;
  @override
  void initState() {
    super.initState();
    _prayerViewModel = PrayerViewModel(
      appRepository: context.read<AppRepository>(),
      schedulePrayerNotificationsUseCase: context
          .read<SchedulePrayerNotificationsUseCase>(),
    );
    _fetchUserViewModel = FetchUserViewModel(
      userRepository: context.read<UserRepository>(),
      authRepository: context.read<AuthRepository>(),
    );
    _prayerTimesViewModel = PrayerTimesViewModel(
      prayerTimeUseCase: context.read<PrayerTimeUseCase>(),
    );
    _placeSelectorViewModel = PlaceSelectorViewModel(
      placesRepository: context.read<PlacesRepository>(),
    );
    _prayerTimesViewModel.getPrayerTimes.handleError(
      context,
      showSnackBar: true,
    );
    _editProfileViewModel = EditProfileViewModel(
      userRepository: context.read<UserRepository>(),
      authRepository: context.read<AuthRepository>(),
      appRepository: context.read<AppRepository>(),
      schedulePrayerNotificationsUseCase: context
          .read<SchedulePrayerNotificationsUseCase>(),
    );
    _placeSelectorViewModel.countrySelector.getCountries.handleError(
      context,
      showSnackBar: true,
    );
    _editProfileViewModel.updateUserLocation.handleError(
      context,
      showSnackBar: true,
    );
    _editProfileViewModel.updateUserLocation.handleCompleted(
      context,
      successMessage: 'Konum başarıyla güncellendi!',
      onCompleted: (_) async {
        final updatedUser = _editProfileViewModel.currentUser.value;
        if (updatedUser.districtId != null &&
            updatedUser.city != null &&
            updatedUser.country != null) {
          await _prayerTimesViewModel.getPrayerTimes.execute((
            districtId: updatedUser.districtId!,
            city: updatedUser.city!,
            country: updatedUser.country!,
            userId: updatedUser.uid,
          ));
        }
        await _prayerViewModel.schedulePrayerNotifications.execute();
      },
    );
    _advertViewModel = AdvertViewModel(
      admobService: context.read<AdMobService>(),
    );
  }

  @override
  void dispose() {
    _prayerViewModel.dispose();
    _prayerTimesViewModel.dispose();
    _placeSelectorViewModel.dispose();
    _editProfileViewModel.dispose();
    _fetchUserViewModel.dispose();
    _advertViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrayerView(
      prayerViewModel: _prayerViewModel,
      user: _fetchUserViewModel.currentUser.value,
      advertViewModel: _advertViewModel,
      prayerTimesViewModel: _prayerTimesViewModel,
      placeSelectorViewModel: _placeSelectorViewModel,
      editProfileViewModel: _editProfileViewModel,
    );
  }
}
