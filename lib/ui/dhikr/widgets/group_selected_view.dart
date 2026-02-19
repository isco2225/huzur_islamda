import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../ui.dart';

class GroupSelectedView extends StatelessWidget {
  const GroupSelectedView({
    super.key,
    required this.isTodaySelected,
    required this.responsive,
    required this.isDialOpen,
    required this.createDhikrViewModel,
    required this.selectedDate,
    required this.fetchDhikrsViewModel,
  });

  final bool isTodaySelected;
  final ResponsiveData responsive;
  final ValueNotifier<bool> isDialOpen;
  final CreateDhikrViewModel createDhikrViewModel;
  final DateTime selectedDate;
  final FetchDhikrsViewModel fetchDhikrsViewModel;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      safeArea: true,
      floatingActionButton: isTodaySelected
          ? DhikrFloatingActionButton(
              groupDhikrs: fetchDhikrsViewModel.groupDhikrs,
              responsive: responsive,
              isDialOpen: isDialOpen,
              onCreateDhikrsForPrayerTapped: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (dialogContext) => CreateDhikrsForPrayerAlertDialog(
                    createDhikrViewModel: createDhikrViewModel,
                  ),
                );
              },
            )
          : null,
      appBar: AppBar(title: const Text('Zikirlerim')),
      body: Column(
        children: [
          DhikrDateSelector(viewModel: fetchDhikrsViewModel),
          Expanded(
            child: DefaultTabController(
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
                    onTap: (index) {},
                    tabs: const [
                      Tab(text: 'Zikirler'),
                      Tab(text: 'Gruplar'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        InfinityScrollableDhikrs(
                          fetchDhikrsViewModel: fetchDhikrsViewModel,
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
                            fetchDhikrsViewModel.fetchDhikrs.execute(
                              selectedDate,
                            );
                          },
                          dhikrs: fetchDhikrsViewModel.dhikrs,
                          hasError: fetchDhikrsViewModel.fetchDhikrs.error,
                          isFetching: fetchDhikrsViewModel.fetchDhikrs.running,
                          isAllItemsFetched:
                              fetchDhikrsViewModel.fetchDhikrs.completed,
                        ),
                        SingleChildScrollView(
                          child: GroupDhikrsCard(
                            viewModel: fetchDhikrsViewModel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
