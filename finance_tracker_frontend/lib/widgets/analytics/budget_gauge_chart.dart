import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Shows a radial gauge for budget utilization.
class BudgetGaugeChart extends StatelessWidget {
  final double spent;
  final double budgeted;

  const BudgetGaugeChart({
    super.key,
    required this.spent,
    required this.budgeted,
  });

  @override
  Widget build(BuildContext context) {
    final percent = budgeted > 0 ? (spent / budgeted).clamp(0.0, 1.5) : 0.0;
    final theme = Theme.of(context);
    Color ringColor = percent < 1.0
        ? theme.colorScheme.primary
        : Colors.redAccent;
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: percent < 1.0 ? percent : 1.0,
                  color: ringColor,
                  radius: 26,
                  showTitle: false,
                  title: '',
                ),
                PieChartSectionData(
                  value: 1.0 - (percent < 1.0 ? percent : 1.0),
                  color: theme.colorScheme.surface.withValues(alpha: 0.13),
                  radius: 26,
                  showTitle: false,
                  title: '',
                ),
              ],
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: 38,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${(spent / (budgeted > 0 ? budgeted : 1) * 100).clamp(0, 150).toStringAsFixed(0)}%",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text("of budget", style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
