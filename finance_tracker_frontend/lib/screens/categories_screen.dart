import 'package:flutter/material.dart';

/// CategoriesScreen: Displays category-based spending summaries (stub implementation).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: const Center(
        child: Text(
          'Category summary coming soon...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
