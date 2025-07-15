import 'package:flutter/material.dart';

/// AccountScreen: User account/authentication page (stub implementation).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: const Center(
        child: Text(
          'User account features coming soon...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
