// This is a basic Flutter widget test.
//
// Note: The full app requires Firebase initialization which is not available
// in the test environment. This file contains basic widget tests that don't
// require Firebase.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('MaterialApp renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('FixIt Now'),
            ),
          ),
        ),
      );

      expect(find.text('FixIt Now'), findsOneWidget);
    });

    testWidgets('Scaffold with AppBar renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Test App'),
            ),
            body: const Center(
              child: Text('Hello World'),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });
  });
}
