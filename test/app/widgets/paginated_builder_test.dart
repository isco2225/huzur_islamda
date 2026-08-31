import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/pagination/paginated_builder.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PaginatedBuilder.listView', () {
    testWidgets('calls onFetch exactly once on init', (tester) async {
      var fetchCount = 0;

      await tester.pumpWidget(
        wrap(
          PaginatedBuilder.listView(
            itemCount: 0,
            itemBuilder: (_, index) => Text('Item $index'),
            onFetch: () async => fetchCount++,
          ),
        ),
      );
      await tester.pump();

      expect(fetchCount, 1);
    });

    testWidgets('renders the items produced by itemBuilder', (tester) async {
      await tester.pumpWidget(
        wrap(
          PaginatedBuilder.listView(
            itemCount: 3,
            itemBuilder: (_, index) => Text('Item $index'),
            onFetch: () async {},
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsNothing);
    });

    testWidgets('does not call onFetch again when rebuilt with new items', (
      tester,
    ) async {
      var fetchCount = 0;
      Widget build(int count) => wrap(
        PaginatedBuilder.listView(
          itemCount: count,
          itemBuilder: (_, index) => Text('Item $index'),
          onFetch: () async => fetchCount++,
        ),
      );

      await tester.pumpWidget(build(1));
      await tester.pumpWidget(build(2));
      await tester.pump();

      expect(fetchCount, 1);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('renders nothing for an empty list', (tester) async {
      await tester.pumpWidget(
        wrap(
          PaginatedBuilder.listView(
            itemCount: 0,
            itemBuilder: (_, index) => Text('Item $index'),
            onFetch: () async {},
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.textContaining('Item'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('PaginatedBuilder.gridView', () {
    testWidgets('calls fetchFunction exactly once on init', (tester) async {
      var fetchCount = 0;

      await tester.pumpWidget(
        wrap(
          PaginatedBuilder.gridView(
            itemCount: 2,
            itemBuilder: (_, index) => Text('Item $index'),
            fetchFunction: () async => fetchCount++,
          ),
        ),
      );
      await tester.pump();

      expect(fetchCount, 1);
    });

    group(
      'item rendering',
      () {
        testWidgets('renders the items produced by itemBuilder', (
          tester,
        ) async {
          await tester.pumpWidget(
            wrap(
              PaginatedBuilder.gridView(
                itemCount: 2,
                itemBuilder: (_, index) => Text('Item $index'),
                fetchFunction: () async {},
              ),
            ),
          );

          expect(find.text('Item 0'), findsOneWidget);
          expect(find.text('Item 1'), findsOneWidget);
        });
      },
    );
  });
}
