import 'package:flutter/material.dart';

// Define color constants for the modern dark theme
const Color kPrimaryColor = Color(0xFFd21947);
const Color kSecondaryColor = Color(0xFF22252d);
const Color kAccentColor = Color(0xFF05ffee);
const Color kBackgroundColor = Color(0xFF16171a);
const Color kCardColor = Color(0xFF22252d);

void main() {
  runApp(const FinanceTrackerApp());
}

///
/// PUBLIC_INTERFACE
/// The root widget for the finance tracker mobile app.
/// Establishes the dark theme and navigation structure.
///
class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: kPrimaryColor,
          secondary: kAccentColor,
          surface: kCardColor,
        ),
        scaffoldBackgroundColor: kBackgroundColor,
        cardColor: kCardColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSecondaryColor,
          elevation: 1,
          iconTheme: IconThemeData(color: kAccentColor),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: kSecondaryColor,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthNavigation(),
    );
  }
}

///
/// AUTH_NAVIGATION
/// Handles route to authentication (Login/Register) or main Dashboard.
/// In a complete app would check authentication state; here always shows Login.
///
class AuthNavigation extends StatefulWidget {
  const AuthNavigation({super.key});

  @override
  State<AuthNavigation> createState() => _AuthNavigationState();
}

class _AuthNavigationState extends State<AuthNavigation> {
  bool _isAuthenticated = false;
  bool _showLogin = true;

  // Placeholder: simulate user auth and page switching.
  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onSwitchToRegister() {
    setState(() {
      _showLogin = false;
    });
  }

  void _onSwitchToLogin() {
    setState(() {
      _showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const MainScaffold();
    }
    return _showLogin
        ? LoginScreen(
            onLogin: _onAuthenticated,
            onSwitchToRegister: _onSwitchToRegister,
          )
        : RegisterScreen(
            onRegister: _onAuthenticated,
            onSwitchToLogin: _onSwitchToLogin,
          );
  }
}

///
/// MAIN_SCAFFOLD
/// PUBLIC_INTERFACE
/// Main app shell with bottom navigation between Dashboard, Transactions, Budgets, and Charts.
///
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    ChartsScreen(),
  ];

  static const List<BottomNavigationBarItem> _bottomNavItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.swap_horiz_outlined),
      label: 'Transactions',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_balance_wallet_outlined),
      label: 'Budgets',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.pie_chart_outline),
      label: 'Charts',
    ),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

///
/// LOGIN SCREEN
/// PUBLIC_INTERFACE
/// Modern, minimalistic placeholder for Login.
///
class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onSwitchToRegister;
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSwitchToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: kSecondaryColor,
      ),
      body: Center(
        child: Card(
          color: kCardColor,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_open, size: 48, color: kAccentColor),
                const SizedBox(height: 20),
                const Text(
                  'Sign in to Finance Tracker',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Login', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSwitchToRegister,
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: kAccentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///
/// REGISTER SCREEN
/// PUBLIC_INTERFACE
/// Modern, minimalistic placeholder for Register.
///
class RegisterScreen extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onSwitchToLogin;
  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onSwitchToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: kSecondaryColor,
      ),
      body: Center(
        child: Card(
          color: kCardColor,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add, size: 48, color: kAccentColor),
                const SizedBox(height: 20),
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Register', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSwitchToLogin,
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(color: kAccentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///
/// DASHBOARD SCREEN
/// PUBLIC_INTERFACE
/// Minimal placeholder for Dashboard.
///
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: kSecondaryColor,
      ),
      body: Center(
        child: Card(
          color: kCardColor,
          margin: const EdgeInsets.all(32),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Dashboard\n(Recent transactions & overview)',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

///
/// TRANSACTIONS SCREEN
/// PUBLIC_INTERFACE
/// Minimal placeholder for Transactions list & management.
///
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: kSecondaryColor,
      ),
      body: Center(
        child: Card(
          color: kCardColor,
          margin: const EdgeInsets.all(32),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Transactions\n(Create, Edit, Delete)',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

///
/// BUDGETS SCREEN
/// PUBLIC_INTERFACE
/// Minimal placeholder for Budgets management.
///
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: kSecondaryColor,
      ),
      body: Center(
        child: Card(
          color: kCardColor,
          margin: const EdgeInsets.all(32),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Budgets\n(View, Add or Manage Budgets)',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Budget',
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}

///
/// CHARTS SCREEN
/// PUBLIC_INTERFACE
/// Minimal placeholder for Analytics & Charts view.
///
class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts & Analytics'),
        backgroundColor: kSecondaryColor,
      ),
      body: Center(
        child: Card(
          color: kCardColor,
          margin: const EdgeInsets.all(32),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Charts & Analytics\n(Spending visualizations)',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
