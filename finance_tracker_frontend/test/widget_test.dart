import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_frontend/src/app.dart';

void main() {
  testWidgets('App loads and displays something', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    // Check for presence of a page or splash indicator
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
