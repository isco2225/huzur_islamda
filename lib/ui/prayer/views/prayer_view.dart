import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({
    super.key,
    required this.viewModel,
    required this.placeSelectorViewModel,
  });

  final PrayerViewModel viewModel;
  final PlaceSelectorViewModel placeSelectorViewModel;

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
      body: SingleChildScrollView(
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
                  Text(
                    'istanbul,Türkiye',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                child: Column(
                  children: [
                    PrayerTimeDisplayer(
                      name: 'İmsak',
                      time: '06:08',
                      isHighlighted: false,
                    ),
                    _buildDivider(),
                    PrayerTimeDisplayer(
                      name: 'Güneş',
                      time: '07:37',
                      isHighlighted: false,
                    ),
                    _buildDivider(),
                    PrayerTimeDisplayer(
                      name: 'Öğle',
                      time: '12:53',
                      isHighlighted: true,
                    ),
                    _buildDivider(),
                    PrayerTimeDisplayer(
                      name: 'İkindi',
                      time: '15:35',
                      isHighlighted: false,
                    ),
                    _buildDivider(),
                    PrayerTimeDisplayer(
                      name: 'Akşam',
                      time: '17:58',
                      isHighlighted: false,
                    ),
                    _buildDivider(),
                    PrayerTimeDisplayer(
                      name: 'Yatsı',
                      time: '19:20',
                      isHighlighted: false,
                    ),
                  ],
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

              // Show countries.
              ValueListenableBuilder<bool>(
                valueListenable: placeSelectorViewModel.getCountries.running,
                builder: (context, isLoading, child) {
                  return TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            placeSelectorViewModel.getCountries.execute();
                            showDialog<void>(
                              context: context,
                              builder: (context) => PlaceSelector(
                                viewModel: placeSelectorViewModel,
                                onCountryIdSelected: (countryId) {
                                  placeSelectorViewModel.selectCountry.execute(
                                    countryId,
                                  );
                                },
                              ),
                            );
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ülke Seçin'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade200, height: 1, thickness: 1);
  }
}
