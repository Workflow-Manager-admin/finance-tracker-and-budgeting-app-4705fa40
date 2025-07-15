import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../screens/transaction_crud_screen.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    if (txProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (txProvider.transactions.isEmpty) {
      return const Center(child: Text("No transactions. Add one!"));
    }
    return ListView.builder(
      itemCount: txProvider.transactions.length,
      itemBuilder: (ctx, idx) {
        final TransactionModel tx = txProvider.transactions[idx];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: ListTile(
            title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${tx.category} - ${tx.date.toLocal().toString().split(' ')[0]}'),
            trailing: Text('\$${tx.amount.toStringAsFixed(2)}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TransactionCrudScreen(transaction: tx)),
            ),
          ),
        );
      },
    );
  }
}
