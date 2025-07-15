import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/analytics.dart';

/// Shows category breakdown as a pie chart.
class CategoryPieChart extends StatelessWidget {
  final List<CategoryBreakdownItem> breakdown;

  const CategoryPieChart({super.key, required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final totalSpent = breakdown.fold<double>(0.0, (sum, b) => sum + b.spent);
    final theme = Theme.of(context);

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: breakdown
              .asMap()
              .entries
              .where((entry) => entry.value.spent > 0)
              .map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final color = _chartColor(idx, context);
            final percent = totalSpent > 0
                ? (item.spent / totalSpent) * 100
                : 0.0;
            return PieChartSectionData(
              value: item.spent,
              color: color,
              title: "${percent.toStringAsFixed(0)}%",
              radius: 52,
              titleStyle: theme.textTheme.labelMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              badgeWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: color, size: 12),
                  Text(item.category,
                      style: theme.textTheme.bodySmall),
                ],
              ),
              badgePositionPercentageOffset: 1.4,
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 52,
        ),
      ),
    );
  }

  Color _chartColor(int idx, BuildContext context) {
    const predefined = [
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
    return predefined[idx % predefined.length].withOpacity(0.9);
  }
}
