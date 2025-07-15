import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../producers/analytics_provider.dart';
import '../models/analytics.dart';

/// Shows category-based spending summaries as a chart and a list.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(categorySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(categorySummaryProvider),
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            "Failed to load categories: ${err.toString()}",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (List<CategorySummaryItem> items) {
          if (items.isEmpty) {
            return const Center(child: Text("No category spending data."));
          }
          final theme = Theme.of(context);

          // Pie segments for chart colors
          const colors = [
            Color(0xFFD21947),
            Color(0xFF05FFEE),
            Color(0xFF52BA7C),
            Colors.orange,
            Colors.deepPurpleAccent,
            Colors.cyan,
            Colors.amber,
            Colors.indigo,
            Colors.grey,
          ];

          final total = items.fold<double>(0.0, (sum, e) => sum + e.totalSpent);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(categorySummaryProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16),
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Category Spending Summary",
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        total == 0
                            ? const Text("No data to visualize.")
                            : SizedBox(
                                height: 210,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: items.length,
                                  itemBuilder: (context, idx) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 7),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: colors[idx % colors.length],
                                            radius: 20,
                                            child: Text(
                                              "${(items[idx].totalSpent / total * 100).toStringAsFixed(0)}%",
                                              style: const TextStyle(
                                                  fontSize: 13, fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            width: 70,
                                            alignment: Alignment.center,
                                            child: Text(
                                              items[idx].category,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "\$${items[idx].totalSpent.toStringAsFixed(2)}",
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Column(
                      children: [
                        ...items.map(
                          (item) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colors[items.indexOf(item) % colors.length],
                              radius: 16,
                            ),
                            title: Text(item.category),
                            trailing: Text(
                              "\$${item.totalSpent.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
