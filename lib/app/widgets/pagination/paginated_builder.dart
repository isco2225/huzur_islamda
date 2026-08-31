import 'package:flutter/material.dart';

enum _PaginatedBuilderType {
  listView,
  gridView,
}

class PaginatedBuilder extends StatefulWidget {
  const PaginatedBuilder._(
    this._type,
    this.itemCount,
    this.itemBuilder,
    this.onFetch, {
    this.gridDelegate,
  });
  final _PaginatedBuilderType _type;
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Future<void> Function() onFetch;
  final SliverGridDelegate? gridDelegate;

  factory PaginatedBuilder.listView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    required Future<void> Function() onFetch,
  }) {
    return PaginatedBuilder._(
      _PaginatedBuilderType.listView,
      itemCount,
      itemBuilder,
      onFetch,
    );
  }

  factory PaginatedBuilder.gridView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    required Future<void> Function() fetchFunction,
    SliverGridDelegate gridDelegate =
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  }) {
    return PaginatedBuilder._(
      _PaginatedBuilderType.gridView,
      itemCount,
      itemBuilder,
      fetchFunction,
      gridDelegate: gridDelegate,
    );
  }

  @override
  State<PaginatedBuilder> createState() => _PaginatedBuilderState();
}

class _PaginatedBuilderState extends State<PaginatedBuilder> {
  @override
  void initState() {
    super.initState();
    widget.onFetch();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget._type) {
      _PaginatedBuilderType.listView => ListView.builder(
          itemCount: widget.itemCount,
          itemBuilder: (BuildContext context, int index) {
            return widget.itemBuilder(context, index);
          },
        ),
      _PaginatedBuilderType.gridView => GridView.builder(
          gridDelegate: widget.gridDelegate!,
          itemCount: widget.itemCount,
          itemBuilder: (BuildContext context, int index) {
            return widget.itemBuilder(context, index);
          },
        ),
    };
  }
}
