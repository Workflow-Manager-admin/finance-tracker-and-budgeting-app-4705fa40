import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../producers/dashboard_provider.dart';
import '../models/transaction.dart';

/// DashboardScreen: Displays recent transactions and analytics.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(dashboardRecentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Triggers FutureProvider re-fetch
            ref.invalidate(dashboardRecentProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
            children: [
              Card(
                surfaceTintColor: Theme.of(context).colorScheme.surface.withOpacity(0.05),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      recentAsync.when(
                        loading: () => const Center(child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        )),
                        error: (err, _) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error: ${err.toString()}',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        data: (transactions) =>
                          transactions.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text('No recent transactions found.'),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: transactions.length,
                                  itemBuilder: (context, idx) {
                                    final tx = transactions[idx];
                                    return _TransactionListTile(tx: tx);
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              // Add more cards for analytics/summary/quick stats here in the future
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays a nice tile for a transaction (for dashboard & lists)
class _TransactionListTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionListTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = tx.type == "income"
        ? Colors.greenAccent.withValues(alpha: 0.8)
        : Colors.redAccent.withValues(alpha: 0.8);

    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: color,
        child: Icon(
          tx.type == "income" ? Icons.arrow_downward : Icons.arrow_upward,
          color: Colors.white,
        ),
      ),
      title: Text('\${tx.amount.toStringAsFixed(2)} ${tx.currency}',
          style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${tx.category} · ${_prettyDate(tx.date)}'
        '\n${tx.description ?? ''}',
        style: const TextStyle(color: Colors.white70),
      ),
      isThreeLine: tx.description != null && tx.description!.isNotEmpty,
      // Optionally, add a trailing (edit, details, etc)
    );
  }

  /// Returns a user-friendly date string ("Apr 12, 2024")
  static String _prettyDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }
    return "${_monthStr(date.month)} ${date.day}, ${date.year}";
  }

  static String _monthStr(int month) {
    // Months 1-12
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month.clamp(1, 12)];
  }
}
