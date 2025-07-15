import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';

class TransactionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final categoryTotals = txProvider.categoryTotals();
    if (txProvider.transactions.isEmpty) {
      return const Center(child: Text("No data to visualize"));
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 18),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    final idx = categoryTotals.keys.toList().indexOf(entry.key);
                    final colors = [
                      Colors.pinkAccent,
                      Colors.tealAccent,
                      Colors.orangeAccent,
                      Colors.lightBlueAccent,
                      Colors.greenAccent,
                      Colors.purpleAccent
                    ];
                    return PieChartSectionData(
                      color: colors[idx % colors.length],
                      value: entry.value,
                      title: entry.key,
                      titleStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                    );
                  }).toList(),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Amounts per Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: categoryTotals.isEmpty ? 10 : categoryTotals.values.reduce((a, b) => a > b ? a : b) + 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                    )),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < categoryTotals.length) {
                          return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(categoryTotals.keys.elementAt(idx),
                                  style: const TextStyle(fontSize: 13, color: Colors.white)));
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 42,
                    )),
                  ),
                  barGroups: List.generate(
                    categoryTotals.length,
                    (idx) => BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                            toY: categoryTotals.values.elementAt(idx),
                            color: Theme.of(context).colorScheme.tertiary)
                      ],
                      showingTooltipIndicators: [],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
