import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../domain/domain.dart';
import '../../ui.dart';

class PrayerView extends StatefulWidget {
  const PrayerView({
    super.key,
    required this.prayerTimesViewModel,
    required this.placeSelectorViewModel,
    required this.editProfileViewModel,
    required this.user,
  });

  final PrayerTimesViewModel prayerTimesViewModel;
  final PlaceSelectorViewModel placeSelectorViewModel;
  final EditProfileViewModel editProfileViewModel;
  final User user;
  @override
  State<PrayerView> createState() => _PrayerViewState();
}

class _PrayerViewState extends State<PrayerView> {
  @override
  void initState() {
    super.initState();
    // ekran ilk açıldığında namaz vakitlerini getir.
    // eğer kullanıcının daha önce girdiği konum varsa, onu kullanır.
    // eğer kullanıcının daha önce girdiği konum yoksa, konum seçme ekranını gösterir.
    if (widget.user.districtId != null &&
        widget.user.city != null &&
        widget.user.country != null) {
      widget.prayerTimesViewModel.getPrayerTimes.execute((
        districtId: widget.user.districtId!,
        city: widget.user.city!,
        country: widget.user.country!,
        userId: widget.user.uid,
      ));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.placeSelectorViewModel.countrySelector.getCountries.execute();
          showDialog<void>(
            context: context,
            builder: (context) => PlaceSelector(
              viewModel: widget.placeSelectorViewModel,
              editProfileViewModel: widget.editProfileViewModel,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      appBar: AppBar(
        title: Text('Ezan Vakitleri'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      safeArea: true,
      body: ValueListenableBuilder(
        valueListenable: widget.prayerTimesViewModel.getPrayerTimes.running,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.horizontalPadding,
                vertical: responsive.verticalPadding,
              ),
              child: Column(
                children: [
                  // Header: Konum ve Tarih
                  ValueListenableBuilder<User>(
                    valueListenable: widget.editProfileViewModel.currentUser,
                    builder: (context, user, _) {
                      return PrayerHeader(user: user);
                    },
                  ),
                  SizedBox(height: responsive.spacingMedium),

                  // Namaz Vakitleri Listesi
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: ValueListenableBuilder<PrayerTimes?>(
                      valueListenable: widget.prayerTimesViewModel.prayerTimes,
                      builder: (context, prayerTimes, _) {
                        if (prayerTimes == null) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text('Namaz vakitleri yükleniyor...'),
                            ),
                          );
                        }
                        return PrayerTimesList(prayerTimes: prayerTimes);
                      },
                    ),
                  ),
                  SizedBox(height: responsive.spacingMedium),

                  // Sonraki Vakit İçin Kalan Süre
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sonraki vakit için:',
                      style: TextStyle(
                        fontSize: responsive.isSmallScreen ? 12 : 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(height: responsive.spacingExtraSmall),
                  ValueListenableBuilder<PrayerTimes?>(
                    valueListenable: widget.prayerTimesViewModel.prayerTimes,
                    builder: (context, prayerTimes, _) {
                      return RemainingTimeToNextPrayer(
                        prayerTimes: prayerTimes,
                      );
                    },
                  ),

                  // Yer Seçin Butonu
                  PlaceSelectorButton(
                    placeSelectorViewModel: widget.placeSelectorViewModel,
                    editProfileViewModel: widget.editProfileViewModel,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
