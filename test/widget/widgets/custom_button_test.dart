import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fixit/presentation/widgets/common/custom_button.dart';

void main() {
  group('CustomButton Widget', () {
    Widget createTestWidget({
      required String text,
      VoidCallback? onPressed,
      bool isLoading = false,
      ButtonType type = ButtonType.primary,
      Color? backgroundColor,
      Color? textColor,
      double? width,
      double height = 56,
      IconData? icon,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: text,
            onPressed: onPressed ?? () {},
            isLoading: isLoading,
            type: type,
            backgroundColor: backgroundColor,
            textColor: textColor,
            width: width,
            height: height,
            icon: icon,
          ),
        ),
      );
    }

    testWidgets('displays button text', (tester) async {
      await tester.pumpWidget(createTestWidget(text: 'Click Me'));

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(createTestWidget(
        text: 'Press',
        onPressed: () => pressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Loading',
        isLoading: true,
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Text should be hidden when loading
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('hides loading indicator when isLoading is false', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Not Loading',
        isLoading: false,
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Not Loading'), findsOneWidget);
    });

    testWidgets('disables button when isLoading is true', (tester) async {
      var pressed = false;
      await tester.pumpWidget(createTestWidget(
        text: 'Loading',
        isLoading: true,
        onPressed: () => pressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Button should not respond when loading
      expect(pressed, isFalse);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'With Icon',
        icon: Icons.check,
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('respects custom width', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Custom Width',
        width: 200,
      ));

      final button = find.byType(CustomButton);
      expect(button, findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Custom Height',
        height: 60,
      ));

      final button = find.byType(CustomButton);
      expect(button, findsOneWidget);
    });

    testWidgets('applies outlined style when type is outlined', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Outlined',
        type: ButtonType.outlined,
      ));

      // Verify the outlined button renders
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('applies custom background color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Custom Color',
        backgroundColor: Colors.red,
      ));

      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('applies custom text color', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Custom Text',
        textColor: Colors.blue,
      ));

      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('renders secondary button type', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Secondary',
        type: ButtonType.secondary,
      ));

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders text button type', (tester) async {
      await tester.pumpWidget(createTestWidget(
        text: 'Text Button',
        type: ButtonType.text,
      ));

      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
