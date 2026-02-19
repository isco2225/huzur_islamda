import 'package:flutter/material.dart';
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
                selectedDate: selectedDate,
              ),
            );
          },
        );
      },
    );
  }
}
