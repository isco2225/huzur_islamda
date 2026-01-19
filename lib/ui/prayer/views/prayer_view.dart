import 'package:flutter/foundation.dart';
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
  late final ValueNotifier<bool> _isLocationSelected;
  @override
  void initState() {
    super.initState();
    // if user has location, get prayer times, otherwise show place selector.
    if ((widget.user.districtId != null &&
            widget.user.districtId!.isNotEmpty) &&
        (widget.user.city != null && widget.user.city!.isNotEmpty) &&
        (widget.user.country != null && widget.user.country!.isNotEmpty)) {
      widget.prayerTimesViewModel.getPrayerTimes.execute((
        districtId: widget.user.districtId!,
        city: widget.user.city!,
        country: widget.user.country!,
        userId: widget.user.uid,
      ));
      _isLocationSelected = ValueNotifier(true);
    } else {
      _isLocationSelected = ValueNotifier(false);
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted) {
      //     widget.placeSelectorViewModel.countrySelector.getCountries.execute();
      //     showDialog<void>(
      //       context: context,
      //       builder: (context) => PlaceSelector(
      //         viewModel: widget.placeSelectorViewModel,
      //         editProfileViewModel: widget.editProfileViewModel,
      //       ),
      //     );
      //   }
      // });
    }
  }

  @override
  void dispose() {
    _isLocationSelected.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return BaseScaffold(
      appBar: AppBar(
        title: Text('Ezan Vakitleri'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          PrayerPopMenuButton(
            placeSelectorViewModel: widget.placeSelectorViewModel,
            editProfileViewModel: widget.editProfileViewModel,
          ),
        ],
      ),
      safeArea: true,
      body: ValueListenableBuilder(
        valueListenable: _isLocationSelected,
        builder: (context, isLocationSelected, _) {
          if (!isLocationSelected) {
            return Center(
              child: NoLocationToShow(
                onTap: _showPlaceSelector,
                running: ValueNotifier(false),
              ),
            );
          }
          return ValueListenableBuilder(
            valueListenable: widget.prayerTimesViewModel.getPrayerTimes.running,
            builder: (context, isLoading, _) {
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
                      ValueListenableBuilder<User>(
                        valueListenable:
                            widget.editProfileViewModel.currentUser,
                        builder: (context, user, _) {
                          return PrayerHeader(
                            user: user,
                            onLocationTap: () {
                              _showPlaceSelector();
                            },
                          );
                        },
                      ),
                      SizedBox(height: responsive.spacingMedium),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: ValueListenableBuilder<PrayerTimes?>(
                          valueListenable:
                              widget.prayerTimesViewModel.prayerTimes,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sonraki vakit için(${widget.prayerTimesViewModel.prayerTimes.value?.getNextPrayerTime()?.name ?? ''}):',
                          style: TextStyle(
                            fontSize: responsive.isSmallScreen ? 12 : 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      SizedBox(height: responsive.spacingExtraSmall),
                      ValueListenableBuilder<PrayerTimes?>(
                        valueListenable:
                            widget.prayerTimesViewModel.prayerTimes,
                        builder: (context, prayerTimes, _) {
                          return RemainingTimeToNextPrayer(
                            prayerTimes: prayerTimes,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPlaceSelector() {
    widget.placeSelectorViewModel.countrySelector.getCountries.execute();
    if (context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PlaceSelector(
          viewModel: widget.placeSelectorViewModel,
          editProfileViewModel: widget.editProfileViewModel,
          onLocationSelected: () {
            _isLocationSelected.value = true;
          },
        ),
      );
    }
  }
}
