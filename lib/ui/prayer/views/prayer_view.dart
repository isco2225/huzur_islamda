import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class PrayerView extends StatelessWidget {
  const PrayerView({super.key, required this.viewModel});

  final PrayerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
            horizontal: context.horizontalPadding,
            vertical: context.verticalPadding,
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
              SizedBox(height: context.spacingMedium),
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
              SizedBox(height: context.spacingMedium),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sonraki vakit için:',
                  style: TextStyle(
                    fontSize: context.isSmallScreen ? 12 : 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              SizedBox(height: context.spacingExtraSmall),
              RemainingTimeToNextPrayer(),
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
