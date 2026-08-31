import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/base/base_scaffold.dart';

void main() {
  group('BaseScaffold', () {
    testWidgets('renders the body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BaseScaffold(body: Text('Body'))),
      );

      expect(find.text('Body'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('passes appBar and bottomNavigationBar through', (
      tester,
    ) async {
      const navKey = Key('bottom-nav');
      await tester.pumpWidget(
        MaterialApp(
          home: BaseScaffold(
            appBar: AppBar(title: const Text('Title')),
            bottomNavigationBar: const SizedBox(key: navKey, height: 56),
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text('Title')),
        findsOneWidget,
      );
      expect(find.byKey(navKey), findsOneWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
      expect(scaffold.bottomNavigationBar, isA<SizedBox>());
    });

    testWidgets('passes floatingActionButton and backgroundColor through', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BaseScaffold(
            backgroundColor: Colors.amber,
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            body: const Text('Body'),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.amber);
    });

    testWidgets('wraps the body in a SafeArea driven by the safeArea flags', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: BaseScaffold(body: Text('Body'))),
      );
      var safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, isFalse);
      expect(safeArea.bottom, isFalse);
      expect(safeArea.left, isFalse);
      expect(safeArea.right, isFalse);

      await tester.pumpWidget(
        const MaterialApp(
          home: BaseScaffold(safeArea: true, body: Text('Body')),
        ),
      );
      safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isTrue);
      expect(safeArea.left, isTrue);
      expect(safeArea.right, isTrue);

      await tester.pumpWidget(
        const MaterialApp(
          home: BaseScaffold(safeAreaTop: true, body: Text('Body')),
        ),
      );
      safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isFalse);
    });

    testWidgets('forwards canPop to PopScope', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: BaseScaffold(canPop: false, body: Text('B'))),
      );

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });

    testWidgets('tapping the scaffold unfocuses a focused TextField', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: BaseScaffold(
            body: Column(
              children: [
                TextField(focusNode: focusNode),
                const SizedBox(key: Key('empty-area'), height: 300),
              ],
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.tap(find.byKey(const Key('empty-area')));
      await tester.pump();

      expect(focusNode.hasFocus, isFalse);
    });

    group(
      'onScaffoldDoubleTap',
      () {
        // Block-bodied callbacks return null; an arrow callback returning a
        // value (e.g. `() => count++`) additionally crashes the build, see
        // the last test in this group.
        testWidgets('is not invoked during build', (tester) async {
          var doubleTapCount = 0;

          await tester.pumpWidget(
            MaterialApp(
              home: BaseScaffold(
                onScaffoldDoubleTap: () {
                  doubleTapCount++;
                },
                body: const Text('Body'),
              ),
            ),
          );

          expect(doubleTapCount, 0);
        });

        testWidgets('is invoked when the scaffold is double tapped', (
          tester,
        ) async {
          var doubleTapCount = 0;

          await tester.pumpWidget(
            MaterialApp(
              home: BaseScaffold(
                onScaffoldDoubleTap: () {
                  doubleTapCount++;
                },
                body: const SizedBox(key: Key('area'), height: 300),
              ),
            ),
          );
          doubleTapCount = 0;

          await tester.tap(find.byKey(const Key('area')));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(find.byKey(const Key('area')));
          await tester.pumpAndSettle();

          expect(doubleTapCount, 1);
        });

        testWidgets('a callback returning a value does not break the build', (
          tester,
        ) async {
          var doubleTapCount = 0;

          await tester.pumpWidget(
            MaterialApp(
              home: BaseScaffold(
                onScaffoldDoubleTap: () => doubleTapCount++,
                body: const Text('Body'),
              ),
            ),
          );

          expect(tester.takeException(), isNull);
          expect(find.text('Body'), findsOneWidget);
        });
      },
    );
  });
}
