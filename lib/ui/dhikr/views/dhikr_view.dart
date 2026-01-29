import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../ui.dart';

class DhikrView extends StatelessWidget {
  const DhikrView({
    super.key,
    required this.viewModel,
    required this.createDhikrViewModel,
  });

  final FetchDhikrsViewModel viewModel;
  final CreateDhikrViewModel createDhikrViewModel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ValueListenableBuilder<DateTime>(
      valueListenable: viewModel.selectedDate,
      builder: (context, selectedDate, _) {
        final isTodaySelected = selectedDate == today;

        return BaseScaffold(
          safeArea: true,
          floatingActionButton: isTodaySelected
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
                          context: context,
                          builder: (dialogContext) =>
                              CreateDhikrsForPrayerAlertDialog(
                                createDhikrViewModel: createDhikrViewModel,
                              ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          body: Column(
            children: [
              DhikrDateSelector(viewModel: viewModel),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: viewModel.groupDhikrs,
                  builder: (context, groupDhikrs, _) {
                    if (groupDhikrs == null || groupDhikrs.isEmpty) {
                      // Grup zikirleri yoksa sadece normal zikirleri göster
                      return InfinityScrollableDhikrs(
                        fetchDhikrsViewModel: viewModel,
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
                          viewModel.fetchDhikrs.execute(selectedDate);
                        },
                        dhikrs: viewModel.dhikrs,
                        hasError: viewModel.fetchDhikrs.error,
                        isFetching: viewModel.fetchDhikrs.running,
                        isAllItemsFetched: viewModel.fetchDhikrs.completed,
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
                                  fetchDhikrsViewModel: viewModel,
                                  noItemsToShowWidget: isTodaySelected
                                      ? const Center(child: NoDhikrsToShow())
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
                                    viewModel.fetchDhikrs.execute(selectedDate);
                                  },
                                  dhikrs: viewModel.dhikrs,
                                  hasError: viewModel.fetchDhikrs.error,
                                  isFetching: viewModel.fetchDhikrs.running,
                                  isAllItemsFetched:
                                      viewModel.fetchDhikrs.completed,
                                ),
                                // Gruplar sekmesi
                                SingleChildScrollView(
                                  child: GroupDhikrsCard(viewModel: viewModel),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
