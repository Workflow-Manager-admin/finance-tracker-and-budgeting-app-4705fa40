import 'package:flutter/material.dart';
import '../../models/analytics.dart';

/// Shows budget, spent, and remaining as a progress bar for a given category.
class CategoryLinearProgress extends StatelessWidget {
  final CategoryBreakdownItem categoryItem;

  const CategoryLinearProgress({super.key, required this.categoryItem});

  @override
  Widget build(BuildContext context) {
    final percent = categoryItem.budgeted > 0
        ? (categoryItem.spent / categoryItem.budgeted).clamp(0.0, 1.5)
        : 0.0;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                categoryItem.category,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              "\$${categoryItem.spent.toStringAsFixed(2)}"
              " / \$${categoryItem.budgeted.toStringAsFixed(2)}",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent < 1.0 ? percent : 1.0,
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.11),
          color: percent < 1.01
              ? theme.colorScheme.primary
              : Colors.redAccent,
          minHeight: 7,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
