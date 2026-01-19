import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../domain/domain.dart';
import '../../../ui.dart';

class InfinityScrollableDhikrs extends StatefulWidget {
  const InfinityScrollableDhikrs({
    required this.fetchDhikrsViewModel,
    required this.noItemsToShowWidget,
    required this.onFetch,
    required this.dhikrs,
    required this.hasError,
    required this.isFetching,
    required this.isAllItemsFetched,
    super.key,
  });

  final FetchDhikrsViewModel fetchDhikrsViewModel;
  final Widget noItemsToShowWidget;
  final VoidCallback onFetch;
  final ValueListenable<List<Dhikr>?> dhikrs;
  final ValueListenable<bool> hasError;
  final ValueListenable<bool> isFetching;
  final ValueListenable<bool> isAllItemsFetched;

  @override
  State<InfinityScrollableDhikrs> createState() =>
      _InfinityScrollableDhikrsState();
}

class _InfinityScrollableDhikrsState extends State<InfinityScrollableDhikrs> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Dhikr>?>(
      valueListenable: widget.dhikrs,
      builder: (context, dhikrs, _) {
        if (dhikrs == null) {
          return widget.noItemsToShowWidget;
        }
        return InfinityScrollable.listView(
          scrollController: null,
          bottomPadding: 8,
          initializeFailureWidget: Center(
            child: Column(
              children: [
                Text('Zikirler yüklenemedi. Tekrar deneyiniz.'),
                TextButton(
                  onPressed: () {
                    widget.onFetch();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
          fetchMoreFailureWidget: Column(
            children: [Text('Zikirler yüklenemedi. Tekrar deneyiniz.')],
          ),
          itemCount: dhikrs.length,
          itemBuilder: (context, index) {
            final dhikr = dhikrs[index];
            return DhikrCard(
              dhikr: dhikr,
              onRefresh: () {
                // fetch the dhikrs for the selected date
                final selectedDate =
                    widget.fetchDhikrsViewModel.selectedDate.value;
                widget.fetchDhikrsViewModel.fetchDhikrs.execute(selectedDate);
              },
            );
          },
          isFetching: widget.isFetching.value,
          onFetchMore: () => widget.onFetch(),
          isAllItemsFetched: widget.isAllItemsFetched.value,
          fetchingFirstItems: const SizedBox.shrink(),
          fetchingMoreItemsWidget: const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          noItemsToShowWidget: widget.noItemsToShowWidget,
          hasError: widget.hasError.value,
        );
      },
    );
  }
}
