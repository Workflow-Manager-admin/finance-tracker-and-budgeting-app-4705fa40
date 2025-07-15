import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_frontend/widgets/error_widget.dart';

void main() {
  testWidgets('AppErrorWidget displays provided message', (WidgetTester tester) async {
    const String errorMessage = 'Something went wrong!';
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: AppErrorWidget(message: errorMessage),
      ),
    ));

    expect(find.text(errorMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  // Future: Add widget tests for forms and network error flows.
}
