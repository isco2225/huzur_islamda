import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ScrollItemState {
  _noItems,
  _noItemsFetching,
  _noItemsFailure,
  _hasItems,
  _hasItemsFetching,
  _hasItemsFailure,
  _allItemsFetched,
}

enum InfinityScrollableType {
  _gridView,
  _listView,
}

class InfinityScrollable extends StatefulWidget {
  const InfinityScrollable._({
    required this.type,
    required this.itemCount,
    required this.itemBuilder,
    required this.isFetching,
    required this.initializeFailureWidget,
    required this.fetchMoreFailureWidget,
    required this.onFetchMore,
    required this.isAllItemsFetched,
    required this.fetchingFirstItems,
    required this.fetchingMoreItemsWidget,
    required this.noItemsToShowWidget,
    required this.hasError,
    required this.gridDelegate,
    required this.bottomPadding,
    required this.scrollController,
    required this.scrollDirection,
    required this.reverse,
  });
  final InfinityScrollableType type;
  final int itemCount;
  final bool isFetching;
  final bool hasError;
  final bool isAllItemsFetched;
  final IndexedWidgetBuilder itemBuilder;
  final Widget initializeFailureWidget;
  final Widget fetchMoreFailureWidget;
  final Widget fetchingFirstItems;
  final Widget fetchingMoreItemsWidget;
  final Widget noItemsToShowWidget;
  final void Function() onFetchMore;
  final SliverGridDelegate gridDelegate;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final double bottomPadding;
  final bool reverse;

  factory InfinityScrollable.gridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required Widget initializeFailureWidget,
    required Widget fetchMoreFailureWidget,
    required void Function() onFetchMore,
    required SliverGridDelegate gridDelegate,
    required bool isFetching,
    required bool isAllItemsFetched,
    required Widget fetchingFirstItems,
    required Widget fetchingMoreItemsWidget,
    required Widget noItemsToShowWidget,
    required bool hasError,
    required double bottomPadding,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    required ScrollController? scrollController,
  }) {
    return InfinityScrollable._(
      type: InfinityScrollableType._gridView,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      initializeFailureWidget: initializeFailureWidget,
      fetchMoreFailureWidget: fetchMoreFailureWidget,
      onFetchMore: onFetchMore,
      isFetching: isFetching,
      isAllItemsFetched: isAllItemsFetched,
      fetchingFirstItems: fetchingFirstItems,
      fetchingMoreItemsWidget: fetchingMoreItemsWidget,
      noItemsToShowWidget: noItemsToShowWidget,
      hasError: hasError,
      bottomPadding: bottomPadding,
      scrollDirection: scrollDirection,
      reverse: reverse,
      scrollController: scrollController,
    );
  }

  factory InfinityScrollable.listView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required Widget initializeFailureWidget,
    required Widget fetchMoreFailureWidget,
    required void Function() onFetchMore,
    required bool isFetching,
    required bool isAllItemsFetched,
    required Widget fetchingFirstItems,
    required Widget fetchingMoreItemsWidget,
    required Widget noItemsToShowWidget,
    required bool hasError,
    required double bottomPadding,
    ScrollController? scrollController,
    Axis? scrollDirection,
    bool reverse = false,
  }) {
    return InfinityScrollable._(
      type: InfinityScrollableType._listView,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 0.5,
        mainAxisExtent: 100,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      initializeFailureWidget: initializeFailureWidget,
      fetchMoreFailureWidget: fetchMoreFailureWidget,
      onFetchMore: onFetchMore,
      isFetching: isFetching,
      isAllItemsFetched: isAllItemsFetched,
      fetchingFirstItems: fetchingFirstItems,
      fetchingMoreItemsWidget: fetchingMoreItemsWidget,
      noItemsToShowWidget: noItemsToShowWidget,
      hasError: hasError,
      bottomPadding: bottomPadding,
      scrollController: scrollController,
      scrollDirection: scrollDirection ?? Axis.vertical,
      reverse: reverse,
    );
  }
  @override
  State<InfinityScrollable> createState() => _InfinityScrollableState();
}

class _InfinityScrollableState extends State<InfinityScrollable> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_fetchMoreOnScroll);
  }

  @override
  void dispose() {
    // If widget.scrollController is not null then dispose it.
    // Else do not dispose it. Let the parent widget dispose it.
    _scrollController.removeListener(_fetchMoreOnScroll);
    if (widget.scrollController == null) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentScrollState = _currentScrollState();
    if (widget.itemCount == 0 &&
        currentScrollState == ScrollItemState._allItemsFetched) {
      return widget.noItemsToShowWidget;
    }
    return switch (currentScrollState) {
      ScrollItemState._noItems => widget.noItemsToShowWidget,
      ScrollItemState._noItemsFetching => widget.fetchingFirstItems,
      ScrollItemState._noItemsFailure => widget.initializeFailureWidget,
      _ => switch (widget.type) {
          InfinityScrollableType._gridView => GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: widget.gridDelegate,
              scrollDirection: widget.scrollDirection,
              reverse: widget.reverse,
              controller:
                  widget.scrollController == null ? _scrollController : null,
              padding: EdgeInsets.only(bottom: widget.bottomPadding),
              itemCount: switch (currentScrollState) {
                ScrollItemState._hasItems => widget.itemCount,
                ScrollItemState._hasItemsFetching => widget.itemCount + 1,
                ScrollItemState._hasItemsFailure => widget.itemCount + 1,
                ScrollItemState._allItemsFetched => widget.itemCount,
                _ => 0,
              },
              itemBuilder: (context, index) {
                if (currentScrollState == ScrollItemState._hasItemsFetching &&
                    index == widget.itemCount) {
                  return widget.fetchingMoreItemsWidget;
                }
                if (currentScrollState == ScrollItemState._hasItemsFailure &&
                    index == widget.itemCount) {
                  return widget.fetchMoreFailureWidget;
                }
                return widget.itemBuilder.call(context, index);
              },
            ),
          InfinityScrollableType._listView => ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: widget.scrollDirection,
              reverse: widget.reverse,
              controller: _scrollController,
              itemCount: switch (currentScrollState) {
                ScrollItemState._hasItems => widget.itemCount,
                ScrollItemState._hasItemsFetching => widget.itemCount + 1,
                ScrollItemState._hasItemsFailure => widget.itemCount + 1,
                ScrollItemState._allItemsFetched => widget.itemCount,
                _ => 0,
              },
              itemBuilder: (context, index) {
                if (currentScrollState == ScrollItemState._hasItemsFetching &&
                    index == widget.itemCount) {
                  return widget.fetchingMoreItemsWidget;
                }
                if (currentScrollState == ScrollItemState._hasItemsFailure &&
                    index == widget.itemCount) {
                  return widget.fetchMoreFailureWidget;
                }
                return widget.itemBuilder.call(context, index);
              },
            ),
        }
    };
  }

  ScrollItemState _currentScrollState() {
    if (widget.isAllItemsFetched) {
      return ScrollItemState._allItemsFetched;
    }
    if (widget.itemCount == 0) {
      if (widget.isFetching) return ScrollItemState._noItemsFetching;
      if (widget.hasError) {
        return ScrollItemState._noItemsFailure;
      }
      return ScrollItemState._noItems;
    }
    if (widget.isFetching) return ScrollItemState._hasItemsFetching;
    if (widget.hasError) {
      return ScrollItemState._hasItemsFailure;
    }
    return ScrollItemState._hasItems;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) {
      return false;
    }

    final position = _scrollController.position;

    if (position.userScrollDirection == ScrollDirection.forward) {
      return false;
    }

    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    return currentScroll >= maxScroll;
  }

  void _fetchMoreOnScroll() {
    if (!_isBottom) return;
    if (widget.isFetching) return;
    if (widget.hasError) return;
    if (widget.isAllItemsFetched) return;
    widget.onFetchMore();
  }
}
