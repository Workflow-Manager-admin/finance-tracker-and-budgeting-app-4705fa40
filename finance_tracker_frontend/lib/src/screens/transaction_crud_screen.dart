import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/error_banner.dart';
import 'dashboard_screen.dart';

class TransactionCrudScreen extends StatefulWidget {
  static const routeName = '/transaction_crud';
  final TransactionModel? transaction; // If null, "Add" mode. Else, "Edit".
  const TransactionCrudScreen({super.key, this.transaction});

  @override
  State<TransactionCrudScreen> createState() => _TransactionCrudScreenState();
}

class _TransactionCrudScreenState extends State<TransactionCrudScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _category = '';
  double _amount = 0.0;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _title = widget.transaction!.title;
      _category = widget.transaction!.category;
      _amount = widget.transaction!.amount;
      _date = widget.transaction!.date;
    }
  }

  Future<void> _submit({bool isEdit = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    txProvider.clearError();
    final tx = TransactionModel(
      id: widget.transaction?.id,
      title: _title,
      category: _category,
      amount: _amount,
      date: _date,
    );

    bool success = false;
    if (isEdit) {
      success = await txProvider.updateTransaction(token: authProvider.token!, tx: tx);
    } else {
      success = await txProvider.addTransaction(token: authProvider.token!, tx: tx);
    }
    if (success) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    }
    // If error, will be shown via error banner
  }

  Future<void> _delete() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    txProvider.clearError();
    final id = widget.transaction?.id;
    if (id == null) return;
    final deleted = await txProvider.deleteTransaction(token: authProvider.token!, txId: id);
    if (deleted) {
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    }
    // If error, will be shown via error banner
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    final txProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        actions: isEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: _delete,
                )
              ]
            : null,
      ),
      body: Center(
        child: SizedBox(
          width: 340,
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            margin: const EdgeInsets.all(22),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (txProvider.errorMsg != null)
                      ErrorBanner(
                        message: txProvider.errorMsg ?? "Unknown error",
                        onClose: () => txProvider.clearError(),
                      ),
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _title = val ?? '',
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _category = val ?? '',
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: _amount == 0.0 ? '' : _amount.toString(),
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                          val == null || double.tryParse(val) == null ? "Enter valid number" : null,
                      onSaved: (val) => _amount = double.tryParse(val ?? '0') ?? 0,
                    ),
                    const SizedBox(height: 8),
                    InputDatePickerFormField(
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: _date,
                      fieldLabelText: 'Date',
                      onDateSaved: (val) => _date = val,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _submit(isEdit: isEdit),
                        child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
