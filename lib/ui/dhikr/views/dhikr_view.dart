import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class DhikrView extends StatefulWidget {
  const DhikrView({
    super.key,
    required this.viewModel,
    required this.createDhikrViewModel,
  });

  final FetchDhikrsViewModel viewModel;
  final CreateDhikrViewModel createDhikrViewModel;

  @override
  State<DhikrView> createState() => _DhikrViewState();
}

class _DhikrViewState extends State<DhikrView> {
  ValueNotifier<bool> isOnGroupTap = ValueNotifier<bool>(false);
  @override
  void dispose() {
    isOnGroupTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.viewModel.selectedDate,
        isOnGroupTap,
      ]),
      builder: (context, _) {
        final isTodaySelected = widget.viewModel.selectedDate.value == today;
        final selectedDate = widget.viewModel.selectedDate.value;
        return BaseScaffold(
          safeArea: true,
          floatingActionButton: isTodaySelected && !isOnGroupTap.value
              ? FloatingActionButton(
                  onPressed: () {
                    context.pushCreateDhikr();
                  },
                  heroTag: 'create_dhikr',
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          appBar: AppBar(
            title: const Text('Zikirlerim'),
            actions: [
              isTodaySelected
                  ? DhikrPopMenuButton(
                      onCreateDhikrsForPrayerTapped: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (dialogContext) =>
                              CreateDhikrsForPrayerAlertDialog(
                                createDhikrViewModel:
                                    widget.createDhikrViewModel,
                              ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          body: Column(
            children: [
              DhikrDateSelector(viewModel: widget.viewModel),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget.viewModel.isInitialLoading,
                  builder: (context, isInitialLoading, _) {
                    if (isInitialLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ValueListenableBuilder(
                      valueListenable: widget.viewModel.groupDhikrs,
                      builder: (context, groupDhikrs, _) {
                        if (groupDhikrs == null || groupDhikrs.isEmpty) {
                          return InfinityScrollableDhikrs(
                            fetchDhikrsViewModel: widget.viewModel,
                            noItemsToShowWidget: isTodaySelected
                                ? const Center(child: NoDhikrsToShow())
                                : const Center(
                                    child: Text(
                                      'Bu tarih için zikir yok.',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                            onFetch: () {
                              widget.viewModel.fetchDhikrs.execute(
                                selectedDate,
                              );
                            },
                            dhikrs: widget.viewModel.dhikrs,
                            hasError: widget.viewModel.fetchDhikrs.error,
                            isFetching: widget.viewModel.fetchDhikrs.running,
                            isAllItemsFetched:
                                widget.viewModel.fetchDhikrs.completed,
                          );
                        }
                        // Grup zikirleri varsa sekmeleri göster
                        return DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: AppColors.primary,
                                unselectedLabelColor: Colors.grey[600],
                                indicatorColor: AppColors.primary,
                                indicatorWeight: 2,
                                indicatorSize: TabBarIndicatorSize.label,
                                dividerColor: Colors.transparent,
                                onTap: (index) {
                                  isOnGroupTap.value = index == 1;
                                },
                                tabs: const [
                                  Tab(text: 'Zikirler'),
                                  Tab(text: 'Gruplar'),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    // Zikirler sekmesi
                                    InfinityScrollableDhikrs(
                                      fetchDhikrsViewModel: widget.viewModel,
                                      noItemsToShowWidget: isTodaySelected
                                          ? const Center(
                                              child: NoDhikrsToShow(),
                                            )
                                          : const Center(
                                              child: Text(
                                                'Bu tarih için zikir yok.',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                      onFetch: () {
                                        widget.viewModel.fetchDhikrs.execute(
                                          selectedDate,
                                        );
                                      },
                                      dhikrs: widget.viewModel.dhikrs,
                                      hasError:
                                          widget.viewModel.fetchDhikrs.error,
                                      isFetching:
                                          widget.viewModel.fetchDhikrs.running,
                                      isAllItemsFetched: widget
                                          .viewModel
                                          .fetchDhikrs
                                          .completed,
                                    ),
                                    // Gruplar sekmesi
                                    SingleChildScrollView(
                                      child: GroupDhikrsCard(
                                        viewModel: widget.viewModel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
