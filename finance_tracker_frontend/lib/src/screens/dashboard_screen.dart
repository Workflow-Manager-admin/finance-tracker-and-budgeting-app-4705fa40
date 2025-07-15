import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list.dart';
import '../widgets/transaction_chart.dart';
import 'login_screen.dart';
import 'transaction_crud_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchOnAuth();
  }

  void _fetchOnAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      if (authProvider.isAuthenticated && !_initialized) {
        await txProvider.fetchTransactions(token: authProvider.token!);
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  Future<void> _refreshTx() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    await txProvider.fetchTransactions(token: authProvider.token!);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final txProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
              onPressed: () {
                authProvider.logout();
                Navigator.pushReplacementNamed(context, LoginScreen.routeName);
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'Recent'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: _refreshTx,
            child: TransactionList(),
          ),
          TransactionChart(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, TransactionCrudScreen.routeName);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Transaction',
      ),
    );
  }
}
