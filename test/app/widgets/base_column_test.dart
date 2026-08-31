import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/base/base_column.dart';

Widget wrapInBox(Widget child, {double height = 200}) {
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(height: height, width: 300, child: child),
      ),
    ),
  );
}

List<Widget> tallChildren(int count) => [
  for (var i = 0; i < count; i++)
    SizedBox(height: 100, child: Text('Item $i')),
];

void main() {
  group('BaseColumn', () {
    testWidgets('renders its children', (tester) async {
      await tester.pumpWidget(
        wrapInBox(
          const BaseColumn(children: [Text('One'), Text('Two')]),
          height: 400,
        ),
      );

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders an empty Column when children is null', (
      tester,
    ) async {
      await tester.pumpWidget(wrapInBox(const BaseColumn()));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('forwards layout parameters to the inner Column', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInBox(
          const BaseColumn(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.up,
            textDirection: TextDirection.rtl,
            children: [Text('x')],
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.end);
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.verticalDirection, VerticalDirection.up);
      expect(column.textDirection, TextDirection.rtl);
    });

    testWidgets('defaults to spaceEvenly / center / max', (tester) async {
      await tester.pumpWidget(wrapInBox(const BaseColumn(children: [Text('x')])));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.spaceEvenly);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      expect(column.mainAxisSize, MainAxisSize.max);
    });

    testWidgets('isScrollable true lays out a tall list without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInBox(BaseColumn(isScrollable: true, children: tallChildren(6))),
      );

      expect(tester.takeException(), isNull);
      final sliver = tester.widget<SliverFillRemaining>(
        find.byType(SliverFillRemaining),
      );
      expect(sliver.hasScrollBody, isFalse);
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('isScrollable true lets the user scroll to the last child', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrapInBox(
          BaseColumn(
            isScrollable: true,
            scrollController: controller,
            children: tallChildren(6),
          ),
        ),
      );

      // 6 x 100 content in a 200 viewport leaves 400 of scroll extent.
      expect(controller.position.maxScrollExtent, 400);

      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();

      expect(find.text('Item 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('isScrollable false builds without overflow when it fits', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapInBox(BaseColumn(isScrollable: false, children: tallChildren(2))),
      );

      expect(tester.takeException(), isNull);
      final sliver = tester.widget<SliverFillRemaining>(
        find.byType(SliverFillRemaining),
      );
      expect(sliver.hasScrollBody, isTrue);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('isScrollable false pins the column to the viewport', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrapInBox(
          BaseColumn(
            isScrollable: false,
            scrollController: controller,
            children: tallChildren(2),
          ),
        ),
      );

      expect(controller.position.maxScrollExtent, 0);
      expect(tester.getSize(find.byType(Column)).height, 200);
    });

    testWidgets('isScrollable false overflows for a list taller than the box', (
      tester,
    ) async {
      // Documents the trade-off: a non-scrollable BaseColumn is a plain
      // Column pinned to the viewport, so content taller than the box
      // overflows just like a Column would.
      await tester.pumpWidget(
        wrapInBox(BaseColumn(isScrollable: false, children: tallChildren(6))),
      );

      final exception = tester.takeException();
      expect(exception, isA<FlutterError>());
      expect('$exception', contains('overflowed'));
    });

    testWidgets('passes physics and controller to the scroll view', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrapInBox(
          BaseColumn(
            physics: const NeverScrollableScrollPhysics(),
            scrollController: controller,
            children: const [Text('x')],
          ),
        ),
      );

      final scrollView = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );
      expect(scrollView.physics, isA<NeverScrollableScrollPhysics>());
      expect(scrollView.controller, same(controller));
      expect(scrollView.scrollDirection, Axis.vertical);
    });
  });
}
