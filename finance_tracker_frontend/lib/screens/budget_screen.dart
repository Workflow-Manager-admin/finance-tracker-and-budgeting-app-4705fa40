import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../producers/analytics_provider.dart';
import '../models/analytics.dart';
import '../widgets/analytics/budget_gauge_chart.dart';
import '../widgets/analytics/category_linear_progress.dart';
import '../widgets/analytics/category_pie_chart.dart';

/// BudgetScreen: Shows budget analytics (total/monthly and per category).
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Analytics"),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(budgetAnalyticsProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh analytics",
          ),
        ],
      ),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            "Failed to load analytics: ${err.toString()}",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (BudgetAnalytics analytics) {
          final theme = Theme.of(context);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(budgetAnalyticsProvider),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
              children: [
                Card(
                  color: theme.cardColor,
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                    child: Row(
                      children: [
                        BudgetGaugeChart(spent: analytics.spent, budgeted: analytics.budgeted),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "This Month's Budget",
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.timeline, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    "\$${analytics.spent.toStringAsFixed(2)} spent",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    "\$${analytics.budgeted.toStringAsFixed(2)} budgeted",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.savings, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    "\$${analytics.remaining.toStringAsFixed(2)} remaining",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Spending By Category",
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        CategoryPieChart(breakdown: analytics.categoryBreakdown),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Category Budgets", style: theme.textTheme.titleMedium),
                        const SizedBox(height: 10),
                        ...analytics.categoryBreakdown.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7.0),
                            child: CategoryLinearProgress(categoryItem: cat),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
