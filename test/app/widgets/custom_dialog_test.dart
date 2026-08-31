import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/dialogs/custom_dialog.dart';

void main() {
  group('CustomDialog', () {
    testWidgets('renders title, content and actions inside an AlertDialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomDialog(
            title: 'Delete account',
            content: 'Are you sure?',
            actions: [
              TextButton(onPressed: () {}, child: const Text('Cancel')),
              TextButton(onPressed: () {}, child: const Text('Delete')),
            ],
          ),
        ),
      );

      final dialog = find.byType(AlertDialog);
      expect(dialog, findsOneWidget);
      expect(
        find.descendant(of: dialog, matching: find.text('Delete account')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Are you sure?')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Cancel')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('Delete')),
        findsOneWidget,
      );
    });

    testWidgets('passes the widgets through as AlertDialog.actions', (
      tester,
    ) async {
      const cancelKey = Key('cancel');
      const okKey = Key('ok');
      await tester.pumpWidget(
        MaterialApp(
          home: CustomDialog(
            title: 't',
            content: 'c',
            actions: const [
              SizedBox(key: cancelKey),
              SizedBox(key: okKey),
            ],
          ),
        ),
      );

      final alert = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alert.actions, hasLength(2));
      expect((alert.actions![0] as SizedBox).key, cancelKey);
      expect((alert.actions![1] as SizedBox).key, okKey);
    });

    testWidgets('action callbacks fire when tapped', (tester) async {
      var confirmed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: CustomDialog(
            title: 't',
            content: 'c',
            actions: [
              TextButton(
                onPressed: () => confirmed = true,
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(confirmed, isTrue);
    });

    testWidgets('uses titleLarge and bodyMedium text styles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomDialog(title: 'Title', content: 'Body', actions: []),
        ),
      );

      final context = tester.element(find.byType(CustomDialog));
      final textTheme = Theme.of(context).textTheme;

      expect(
        tester.widget<Text>(find.text('Title')).style,
        textTheme.titleLarge,
      );
      expect(
        tester.widget<Text>(find.text('Body')).style,
        textTheme.bodyMedium,
      );
    });

    testWidgets('works with an empty actions list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomDialog(title: 'Title', content: 'Body', actions: []),
        ),
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
