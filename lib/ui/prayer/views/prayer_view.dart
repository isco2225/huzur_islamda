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
        districtId: widget.user.districtId ?? '',
        city: widget.user.city ?? '',
        country: widget.user.country ?? '',
        userId: widget.user.uid,
      ));
    } else {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konum Seçin'),
          content: const Text('Konum seçiniz'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Seç'),
            ),
          ],
        ),
      );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: widget
                            .placeSelectorViewModel
                            .countrySelector
                            .selectedCountryId,
                        builder: (context, selectedCountryId, _) => Text(
                          selectedCountryId ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '07 kasım 2025'
                        '-Cumartesi',
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.spacingMedium),
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

                        return Column(
                          children: [
                            PrayerTimeDisplayer(
                              name: 'İmsak',
                              time: _formatTime(prayerTimes.fajr),
                              isHighlighted: false,
                            ),
                            _buildDivider(),
                            PrayerTimeDisplayer(
                              name: 'Güneş',
                              time: _formatTime(prayerTimes.dhuhr),
                              isHighlighted: false,
                            ),
                            _buildDivider(),
                            PrayerTimeDisplayer(
                              name: 'Öğle',
                              time: _formatTime(prayerTimes.dhuhr),
                              isHighlighted: true,
                            ),
                            _buildDivider(),
                            PrayerTimeDisplayer(
                              name: 'İkindi',
                              time: _formatTime(prayerTimes.asr),
                              isHighlighted: false,
                            ),
                            _buildDivider(),
                            PrayerTimeDisplayer(
                              name: 'Akşam',
                              time: _formatTime(prayerTimes.maghrib),
                              isHighlighted: false,
                            ),
                            _buildDivider(),
                            PrayerTimeDisplayer(
                              name: 'Yatsı',
                              time: _formatTime(prayerTimes.isha),
                              isHighlighted: false,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: responsive.spacingMedium),
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
                  RemainingTimeToNextPrayer(),

                  // Show place selector button.
                  ValueListenableBuilder<bool>(
                    valueListenable: widget
                        .placeSelectorViewModel
                        .countrySelector
                        .getCountries
                        .running,
                    builder: (context, isLoading, child) {
                      return TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                widget
                                    .placeSelectorViewModel
                                    .countrySelector
                                    .getCountries
                                    .execute();
                                showDialog<void>(
                                  context: context,
                                  builder: (context) => PlaceSelector(
                                    viewModel: widget.placeSelectorViewModel,
                                    editProfileViewModel:
                                        widget.editProfileViewModel,
                                  ),
                                );
                              },
                        child: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Yer Seçin'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, height: 1, thickness: 1);
  }

  /// DateTime'ı "HH:mm" formatına çevirir
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
