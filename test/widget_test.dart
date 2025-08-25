// This is a basic Flutter widget test for MatMate.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matmate/main.dart';

void main() {
  testWidgets('MatMate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the app title is displayed
    expect(find.text('MatMate'), findsOneWidget);

    // Verify that the main navigation tabs are present (using NavigationDestination)
    expect(find.byType(NavigationDestination), findsNWidgets(3));

    // Verify that the input field is present
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('MatMate basic input test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Find the text field and enter a simple calculation
    final textField = find.byType(TextField);
    await tester.enterText(textField, '2 + 2');

    // Verify the text was entered
    expect(find.text('2 + 2'), findsOneWidget);
  });

  testWidgets('MatMate navigation structure test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify navigation bar exists
    expect(find.byType(NavigationBar), findsOneWidget);

    // Verify navigation destinations exist
    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });
}
