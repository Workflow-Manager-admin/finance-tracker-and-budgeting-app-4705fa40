import 'package:flutter/material.dart';

/// BudgetScreen: Shows analytics and budgeting charts (stub implementation).
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget"),
      ),
      body: const Center(
        child: Text(
          'Budget analytics and charts coming soon...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
