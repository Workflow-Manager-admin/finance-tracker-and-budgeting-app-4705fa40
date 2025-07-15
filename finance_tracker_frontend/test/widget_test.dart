import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker_frontend/main.dart';

void main() {
  testWidgets('FinanceTrackerApp renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());

    expect(find.byType(FinanceTrackerApp), findsOneWidget);
    // On initial render - should show LoginScreen title
    expect(find.text('Login'), findsOneWidget);
  });
}
