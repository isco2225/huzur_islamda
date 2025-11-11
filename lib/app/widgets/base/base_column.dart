import 'package:flutter/material.dart';

class BaseColumn extends StatelessWidget {
  const BaseColumn({
    super.key,
    this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textBaseline,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.isScrollable = true,
    this.physics,
    this.scrollController,
  });
  final List<Widget>? children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextBaseline? textBaseline;
  final TextDirection? textDirection;
  final ScrollPhysics? physics;
  final VerticalDirection verticalDirection;
  final ScrollController? scrollController;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      physics: physics,
      controller: scrollController,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: !isScrollable,
          child: Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            textBaseline: textBaseline,
            textDirection: textDirection,
            verticalDirection: verticalDirection,
            key: key,
            children: children ?? [],
          ),
        ),
      ],
    );
  }
}
