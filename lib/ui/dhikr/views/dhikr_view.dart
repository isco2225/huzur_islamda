import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class DhikrView extends StatefulWidget {
  const DhikrView({
    super.key,
    required this.fetchDhikrsViewModel,
    required this.createDhikrViewModel,
  });

  final FetchDhikrsViewModel fetchDhikrsViewModel;
  final CreateDhikrViewModel createDhikrViewModel;

  @override
  State<DhikrView> createState() => _DhikrViewState();
}

class _DhikrViewState extends State<DhikrView> {
  ValueNotifier<bool> isOnGroupTap = ValueNotifier<bool>(false);
  ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);
  @override
  void dispose() {
    isOnGroupTap.dispose();
    isDialOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final responsive = context.responsive;
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.fetchDhikrsViewModel.selectedDate,
        isOnGroupTap,
        widget.fetchDhikrsViewModel.groupDhikrs,
      ]),
      builder: (context, _) {
        final isTodaySelected =
            widget.fetchDhikrsViewModel.selectedDate.value == today;
        final selectedDate = widget.fetchDhikrsViewModel.selectedDate.value;
        final groupDhikrs = widget.fetchDhikrsViewModel.groupDhikrs.value;
        final hasGroups = groupDhikrs != null && groupDhikrs.isNotEmpty;
        if (hasGroups) {
          return ValueListenableBuilder(
            valueListenable: widget.fetchDhikrsViewModel.deleteGroup.running,
            builder: (context, isDeleting, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: isDialOpen,
                builder: (context, dialOpen, _) {
                  return Stack(
                    children: [
                      PopScope(
                        canPop: !dialOpen,
                        onPopInvokedWithResult: (didPop, _) {
                          if (!didPop && dialOpen) {
                            isDialOpen.value = false;
                          }
                        },
                        child: GroupSelectedView(
                          fetchDhikrsViewModel: widget.fetchDhikrsViewModel,
                          createDhikrViewModel: widget.createDhikrViewModel,
                          isTodaySelected: isTodaySelected,
                          responsive: responsive,
                          isDialOpen: isDialOpen,
                          isOnGroupTap: isOnGroupTap,
                          selectedDate: selectedDate,
                        ),
                      ),
                      if (isDeleting)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black26,
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isDialOpen,
          builder: (context, dialOpen, _) {
            return PopScope(
              canPop: !dialOpen,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop && dialOpen) {
                  isDialOpen.value = false;
                }
              },
              child: DhikrSelectedView(
                fetchDhikrsViewModel: widget.fetchDhikrsViewModel,
                createDhikrViewModel: widget.createDhikrViewModel,
                isTodaySelected: isTodaySelected,
                responsive: responsive,
                isDialOpen: isDialOpen,
                isOnGroupTap: isOnGroupTap,
                selectedDate: selectedDate,
              ),
            );
          },
        );
      },
    );
  }
}

class DhikrFloatingActionButton extends StatelessWidget {
  const DhikrFloatingActionButton({
    super.key,
    required this.responsive,
    required this.isDialOpen,
    required this.isOnGroupTap,
    required this.onCreateDhikrsForPrayerTapped,
  });

  final ResponsiveData responsive;
  final ValueNotifier<bool> isDialOpen;
  final ValueNotifier<bool> isOnGroupTap;
  final void Function() onCreateDhikrsForPrayerTapped;

  @override
  Widget build(BuildContext context) {
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
        if (!isOnGroupTap.value)
          SpeedDialChild(
            child: Icon(Icons.add, color: AppColors.primary),
            label: 'Zikir oluştur',
            onTap: () {
              context.pushCreateDhikr();
            },
          ),
      ],
    );
  }
}
