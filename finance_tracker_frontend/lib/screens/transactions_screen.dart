import 'package:flutter/material.dart';

/// TransactionsScreen: Will list all user transactions with CRUD functionality (stub implementation).
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
      ),
      body: const Center(
        child: Text(
          'Transactions list coming soon...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
