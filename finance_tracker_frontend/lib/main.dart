import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/account_screen.dart';

import 'screens/login_screen.dart';
import 'producers/auth_provider.dart';

// PUBLIC_INTERFACE
void main() {
  /// App Entry: Wrap in ProviderScope for Riverpod state management
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  /// Root MaterialApp of the application, with route configuration.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFD21947),    // Project's primary color
          secondary: Color(0xFFE8F2E8),  // Project's secondary color
          tertiary: Color(0xFF05FFEE),   // Project's accent color
        ),
        useMaterial3: true,
      ),
      home: auth.isAuthenticated
          ? const MainNavigation()
          : const LoginScreen(),
    );
  }
}

/// MainNavigation manages the bottom navigation bar and tab switching.
/// Screens: Dashboard, Transactions, Budget, Categories, Account.
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  /// List of top-level screens corresponding to the navigation bar.
  static final List<Widget> _screens = <Widget>[
    DashboardScreen(),
    TransactionsScreen(),
    BudgetScreen(),
    CategoriesScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// BottomNavigationBar for main app navigation.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        // Set consistent bar background using theme.
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
