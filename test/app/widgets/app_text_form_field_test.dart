import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huzur_islamda/app/widgets/text_fields/app_text_form_field.dart';

Widget wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

EditableText editableText(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText));

void main() {
  group('AppTextField', () {
    testWidgets('renders the hint as the label', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField('Email', showText: 'Show', hideText: 'Hide'),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('fires onChanged with the typed text', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        wrap(
          AppTextField(
            'Email',
            showText: 'Show',
            hideText: 'Hide',
            onChanged: changes.add,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'a@b.co');
      await tester.pump();

      expect(changes, ['a@b.co']);
    });

    testWidgets('fires onSubmitted when the field is submitted', (
      tester,
    ) async {
      String? submitted;
      await tester.pumpWidget(
        wrap(
          AppTextField(
            'Email',
            showText: 'Show',
            hideText: 'Hide',
            onSubmitted: (value) => submitted = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'a@b.co');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submitted, 'a@b.co');
    });

    testWidgets('writes into the provided controller', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrap(
          AppTextField(
            'Email',
            showText: 'Show',
            hideText: 'Hide',
            textEditingController: controller,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'hello');

      expect(controller.text, 'hello');
    });

    testWidgets('shows errorText', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            'Email',
            showText: 'Show',
            hideText: 'Hide',
            errorText: 'Email geçersiz',
          ),
        ),
      );

      expect(find.text('Email geçersiz'), findsOneWidget);
    });

    testWidgets('does not obscure text or show a suffix by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField('Email', showText: 'Show', hideText: 'Hide'),
        ),
      );

      expect(editableText(tester).obscureText, isFalse);
      expect(find.text('Show'), findsNothing);
      expect(find.text('Hide'), findsNothing);
    });

    testWidgets('isPassword obscures text and shows the "show" suffix', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            'Password',
            showText: 'Show',
            hideText: 'Hide',
            isPassword: true,
          ),
        ),
      );

      expect(editableText(tester).obscureText, isTrue);
      expect(find.text('Show'), findsOneWidget);
      expect(find.text('Hide'), findsNothing);
    });

    testWidgets('tapping the suffix toggles obscureText back and forth', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            'Password',
            showText: 'Show',
            hideText: 'Hide',
            isPassword: true,
          ),
        ),
      );
      // Focus the field so the suffix is laid out and visible.
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(editableText(tester).obscureText, isFalse);
      expect(find.text('Hide'), findsOneWidget);
      expect(find.text('Show'), findsNothing);

      await tester.tap(find.text('Hide'));
      await tester.pumpAndSettle();

      expect(editableText(tester).obscureText, isTrue);
      expect(find.text('Show'), findsOneWidget);
    });

    testWidgets('isReadOnly blocks input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      var changed = false;
      await tester.pumpWidget(
        wrap(
          AppTextField(
            'Email',
            showText: 'Show',
            hideText: 'Hide',
            isReadOnly: true,
            textEditingController: controller,
            onChanged: (_) => changed = true,
          ),
        ),
      );

      expect(editableText(tester).readOnly, isTrue);

      await tester.enterText(find.byType(TextFormField), 'typed');
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(changed, isFalse);
    });

    testWidgets('passes keyboardType, maxLines and capitalization through', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            'Notes',
            showText: 'Show',
            hideText: 'Hide',
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      );

      final editable = editableText(tester);
      expect(editable.keyboardType, TextInputType.multiline);
      expect(editable.maxLines, 3);
      expect(editable.textCapitalization, TextCapitalization.sentences);
    });

    testWidgets('uses the provided focusNode', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        wrap(
          AppTextField(
            'Email',
            showText: 'Show',
            hideText: 'Hide',
            focusNode: focusNode,
          ),
        ),
      );

      expect(focusNode.hasFocus, isFalse);
      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
    });
  });
}
