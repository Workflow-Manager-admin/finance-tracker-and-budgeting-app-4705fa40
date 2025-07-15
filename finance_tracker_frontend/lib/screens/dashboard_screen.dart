import 'package:flutter/material.dart';

/// DashboardScreen: Displays recent transactions and analytics (stub implementation).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: const Center(
        child: Text(
          'Dashboard content coming soon...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
