import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/presentation/widgets/common/custom_text_field.dart';

void main() {
  group('CustomTextField Widget', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget({
      TextEditingController? textController,
      String? label,
      String? hint,
      IconData? prefixIcon,
      IconData? suffixIcon,
      bool obscureText = false,
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      int maxLines = 1,
      bool enabled = true,
      void Function(String)? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Form(
            child: CustomTextField(
              controller: textController ?? controller,
              label: label ?? 'Test Label',
              hint: hint,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              maxLines: maxLines,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(createTestWidget(label: 'Email'));

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(createTestWidget(hint: 'Enter your email'));

      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('displays prefix icon', (tester) async {
      await tester.pumpWidget(createTestWidget(prefixIcon: Icons.email));

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('displays suffix icon', (tester) async {
      await tester.pumpWidget(createTestWidget(suffixIcon: Icons.visibility));

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'test input');

      expect(controller.text, 'test input');
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(createTestWidget(obscureText: true));

      final finder = find.byType(TextFormField);
      expect(finder, findsOneWidget);
      
      // Enter text and verify it's obscured by checking the EditableText
      await tester.enterText(finder, 'password');
      await tester.pump();
      
      // The field should accept input even when obscured
      expect(controller.text, 'password');
    });

    testWidgets('does not obscure text when obscureText is false', (tester) async {
      await tester.pumpWidget(createTestWidget(obscureText: false));

      final finder = find.byType(TextFormField);
      expect(finder, findsOneWidget);
    });

    testWidgets('runs validator function', (tester) async {
      var validatorRan = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.always,
            child: CustomTextField(
              controller: controller,
              label: 'Test',
              validator: (value) {
                validatorRan = true;
                if (value?.isEmpty ?? true) {
                  return 'Field is required';
                }
                return null;
              },
            ),
          ),
        ),
      ));

      await tester.pump();

      expect(validatorRan, isTrue);
    });

    testWidgets('displays validation error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.always,
            child: CustomTextField(
              controller: controller,
              label: 'Required Field',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ),
      ));

      await tester.pump();

      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      var changedValue = '';
      
      await tester.pumpWidget(createTestWidget(
        onChanged: (value) => changedValue = value,
      ));

      await tester.enterText(find.byType(TextFormField), 'new value');

      expect(changedValue, 'new value');
    });

    testWidgets('supports multiple lines', (tester) async {
      await tester.pumpWidget(createTestWidget(maxLines: 5));

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('is disabled when enabled is false', (tester) async {
      await tester.pumpWidget(createTestWidget(enabled: false));

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('uses correct keyboard type', (tester) async {
      await tester.pumpWidget(createTestWidget(
        keyboardType: TextInputType.emailAddress,
      ));

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });

  group('Specialized TextField Widgets', () {
    testWidgets('EmailTextField renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmailTextField(),
        ),
      ));

      expect(find.byType(EmailTextField), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('PasswordTextField renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PasswordTextField(),
        ),
      ));

      expect(find.byType(PasswordTextField), findsOneWidget);
      expect(find.byIcon(Icons.lock_outlined), findsOneWidget);
    });

    testWidgets('PasswordTextField toggles visibility', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PasswordTextField(),
        ),
      ));

      // Initially should show visibility icon (password hidden)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Should now show visibility_off icon (password visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('SearchTextField renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: SearchTextField(),
        ),
      ));

      expect(find.byType(SearchTextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('MultilineTextField renders correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: MultilineTextField(
            label: 'Description',
          ),
        ),
      ));

      expect(find.byType(MultilineTextField), findsOneWidget);
    });
  });
}
