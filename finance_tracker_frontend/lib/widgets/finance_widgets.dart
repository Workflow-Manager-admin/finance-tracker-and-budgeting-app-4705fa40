import 'package:flutter/material.dart';

const kCardRadius = 16.0;

/// PUBLIC_INTERFACE
/// Card widget for displaying a transaction item.
class TransactionListTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Color color;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onDelete,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardRadius)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.white.withAlpha(25), // 0.1 opacity for avatar
          child: Icon(
            transaction['amount'] >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction['amount'] >= 0 ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        title: Text(
          transaction['description'] ?? 'No Desc',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        subtitle: Text(
          transaction['category'] ?? '',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        trailing: Wrap(
          spacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${transaction['amount'] >= 0 ? '+ ' : '- '}\$${(transaction['amount'] as num).abs().toStringAsFixed(2)}',
              style: TextStyle(
                  color: transaction['amount'] >= 0 ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: "Delete",
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

/// PUBLIC_INTERFACE
/// Card widget for displaying a budget.
class BudgetCard extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final Color color;

  const BudgetCard({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double percent = (limit > 0) ? (spent / limit).clamp(0.0, 1.0) : 0;
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardRadius)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.white12,
              color: percent > 0.8 ? Colors.redAccent : (percent > 0.5 ? Colors.orangeAccent : Colors.greenAccent),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${spent.toStringAsFixed(2)} / \$${limit.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
