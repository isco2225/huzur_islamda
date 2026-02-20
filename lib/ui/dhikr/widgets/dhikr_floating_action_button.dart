import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../app/app.dart';
import '../../../domain/domain.dart';

class DhikrFloatingActionButton extends StatelessWidget {
  const DhikrFloatingActionButton({
    super.key,
    required this.responsive,
    required this.isDialOpen,
    required this.onCreateDhikrsForPrayerTapped,
    required this.groupDhikrs,
  });

  final ResponsiveData responsive;
  final ValueNotifier<bool> isDialOpen;
  final void Function() onCreateDhikrsForPrayerTapped;
  final ValueListenable<List<GroupDhikrData>?> groupDhikrs;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: groupDhikrs,
      builder: (context, groupDhikrs, _) {
        return SpeedDial(
          overlayColor: Colors.grey.shade400,
          backgroundColor: AppColors.primary,
          spacing: responsive.spacingExtraSmall,
          spaceBetweenChildren: responsive.spacingExtraSmall,
          animatedIcon: AnimatedIcons.menu_close,
          activeBackgroundColor: AppColors.primary,
          activeForegroundColor: Colors.black,
          direction: SpeedDialDirection.up,
          closeDialOnPop: true,
          openCloseDial: isDialOpen,
          children: [
            SpeedDialChild(
              child: Icon(Icons.mosque, color: AppColors.primary),
              label: 'Namaz için zikirler',
              onTap: () {
                onCreateDhikrsForPrayerTapped();
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.wb_sunny_outlined, color: AppColors.duaColor),
              label: 'Ruh haline göre zikirler',
              onTap: () {
                context.pushCreateDhikrByMood();
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.add, color: AppColors.primary),
              label: 'Zikir oluştur',
              onTap: () async {
                final dhikrId = await context.pushCreateDhikr<String>();
                if (dhikrId != null && context.mounted) {
                  await context.pushToDhikrDetail(dhikrId);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
