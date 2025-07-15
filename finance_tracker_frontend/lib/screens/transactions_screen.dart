import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../producers/transactions_provider.dart';
import '../models/transaction.dart';

/// TransactionsScreen: Full-featured list/add/edit/delete for transactions.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txListAsync = ref.watch(transactionsListProvider(null));

    /// Used for edit form: opens add or edit as dialog
    Future<void> _showTxForm({TransactionModel? tx}) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ProviderScope(
          // New ProviderScope to avoid leaking internal state to parent.
          child: TransactionFormDialog(transaction: tx),
        ),
      );
      // Always refresh list after a dialog closes (could be improved for performance)
      ref.invalidate(transactionsListProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
      ),
      body: SafeArea(
        child: txListAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
              child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Error: ${err.toString()}",
              style: const TextStyle(color: Colors.redAccent),
            ),
          )),
          data: (transactions) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(transactionsListProvider),
            child: transactions.isEmpty
                ? const Center(child: Text("No transactions yet."))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: transactions.length,
                    itemBuilder: (ctx, idx) {
                      final tx = transactions[idx];
                      return Dismissible(
                        key: ValueKey(tx.id),
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          final ok = await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete transaction?"),
                              content: const Text(
                                  "Are you sure you want to delete this transaction?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            final deleted = await ref
                                .read(transactionCrudProvider.notifier)
                                .delete(tx.id);
                            if (!deleted && context.mounted) {
                              final error = ref.read(transactionCrudProvider).error;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Failed to delete: ${error ?? 'Unknown error'}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else if (context.mounted) {
                              ref.invalidate(transactionsListProvider);
                            }
                          }
                          return ok == true;
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: tx.type == "income"
                                ? Colors.greenAccent.withOpacity(0.7)
                                : Colors.redAccent.withOpacity(0.7),
                            child: Icon(
                              tx.type == "income"
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            "\${tx.amount.toStringAsFixed(2)} ${tx.currency}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              "${tx.category} · ${_prettyDate(tx.date)}${tx.description != null && tx.description!.isNotEmpty ? "\n${tx.description}" : ""}"),
                          isThreeLine: tx.description != null && tx.description!.isNotEmpty,
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _showTxForm(tx: tx),
                            tooltip: "Edit",
                          ),
                          onTap: () => _showTxForm(tx: tx),
                        ),
                      );
                    }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTxForm(),
        icon: const Icon(Icons.add),
        label: const Text("Add"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  static String _prettyDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Today";
    }
    return "${_monthStr(date.month)} ${date.day}, ${date.year}";
  }

  static String _monthStr(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month.clamp(1, 12)];
  }
}

/// Dialog for add/edit a transaction.
class TransactionFormDialog extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  const TransactionFormDialog({Key? key, this.transaction}) : super(key: key);

  @override
  ConsumerState<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends ConsumerState<TransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();

  double? _amount;
  String _currency = 'USD';
  String _category = '';
  String _type = 'expense';
  DateTime _date = DateTime.now();
  String? _description;

  bool _loading = false;

  static const _currencyChoices = ['USD', 'EUR', 'INR'];
  static const _typeChoices = ['income', 'expense'];

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amount = widget.transaction!.amount;
      _currency = widget.transaction!.currency;
      _category = widget.transaction!.category;
      _type = widget.transaction!.type;
      _date = widget.transaction!.date;
      _description = widget.transaction!.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final crudState = ref.watch(transactionCrudProvider);
    final crudNotifier = ref.read(transactionCrudProvider.notifier);

    void _submit() async {
      if (!_formKey.currentState!.validate()) return;
      _formKey.currentState!.save();
      setState(() => _loading = true);

      final payload = {
        'amount': _amount,
        'currency': _currency,
        'category': _category,
        'type': _type,
        'date': _date.toIso8601String(),
        'description': _description,
      };

      bool result;
      if (widget.transaction == null) {
        result = await crudNotifier.create(payload);
        if (result && context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        result = await crudNotifier.update(widget.transaction!.id, payload);
        if (result && context.mounted) {
          Navigator.of(context).pop();
        }
      }
      setState(() => _loading = false);
    }

    return AlertDialog(
      title: Text(widget.transaction == null ? "Add Transaction" : "Edit Transaction"),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (crudState.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(crudState.error!,
                        style: const TextStyle(color: Colors.redAccent)),
                  ),
                TextFormField(
                  initialValue: _amount?.toString(),
                  decoration: const InputDecoration(
                      labelText: "Amount", icon: Icon(Icons.attach_money)),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: false),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Required";
                    final doubleVal = double.tryParse(val);
                    if (doubleVal == null || doubleVal < 0.01) {
                      return "Must be > 0";
                    }
                    return null;
                  },
                  onSaved: (val) => _amount = double.tryParse(val!),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _currency,
                  items: _currencyChoices
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _currency = val!),
                  decoration: const InputDecoration(
                      labelText: "Currency", icon: Icon(Icons.money)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: _category,
                  decoration: const InputDecoration(
                      labelText: "Category", icon: Icon(Icons.category)),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Required" : null,
                  onSaved: (val) => _category = val!,
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: _typeChoices
                      .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                              t[0].toUpperCase() + t.substring(1), style: TextStyle(
                              color: t == 'income'
                                  ? Colors.greenAccent
                                  : Colors.redAccent))))
                      .toList(),
                  onChanged: (val) => setState(() => _type = val!),
                  decoration: const InputDecoration(
                      labelText: "Type", icon: Icon(Icons.sync_alt)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2050),
                                  builder: (context, child) => Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Theme.of(context).colorScheme.primary,
                                        surface: Colors.grey[850]!,
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (picked != null) {
                                  setState(() => _date = picked);
                                }
                              },
                        child: Text(
                          "${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}",
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: _description ?? '',
                  decoration: const InputDecoration(
                      labelText: "Description (optional)",
                      icon: Icon(Icons.note)),
                  maxLines: 2,
                  onSaved: (val) => _description = val,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _loading ? null : () => Navigator.of(context).maybePop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton.icon(
          icon: _loading
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save, size: 18),
          label: Text(widget.transaction == null ? "Add" : "Save"),
          onPressed: _loading ? null : _submit,
        )
      ],
    );
  }
}
