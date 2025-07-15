/*
  Models for analytics and budgeting endpoints: budget analytics and category summary.
 */

class CategoryBreakdownItem {
  final String category;
  final double spent;
  final double budgeted;

  CategoryBreakdownItem({
    required this.category,
    required this.spent,
    required this.budgeted,
  });

  factory CategoryBreakdownItem.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownItem(
      category: json['category'],
      spent: (json['spent'] as num).toDouble(),
      budgeted: (json['budgeted'] as num).toDouble(),
    );
  }
}

class BudgetAnalytics {
  final double budgeted;
  final double spent;
  final double remaining;
  final List<CategoryBreakdownItem> categoryBreakdown;

  BudgetAnalytics({
    required this.budgeted,
    required this.spent,
    required this.remaining,
    required this.categoryBreakdown,
  });

  factory BudgetAnalytics.fromJson(Map<String, dynamic> json) {
    return BudgetAnalytics(
      budgeted: (json['budgeted'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      categoryBreakdown: (json['category_breakdown'] as List)
          .map((e) => CategoryBreakdownItem.fromJson(e))
          .toList(),
    );
  }
}

class CategorySummaryItem {
  final String category;
  final double totalSpent;

  CategorySummaryItem({required this.category, required this.totalSpent});

  factory CategorySummaryItem.fromJson(Map<String, dynamic> json) {
    return CategorySummaryItem(
      category: json['category'],
      totalSpent: (json['total_spent'] as num).toDouble(),
    );
  }
}
