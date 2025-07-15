import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:animations/animations.dart'; // Not directly used here; used in widgets
import 'services/auth_service.dart';
import 'widgets/finance_widgets.dart';
import 'services/transaction_service.dart';
import 'services/budget_service.dart';
import 'widgets/pie_chart.dart';

// Color palette for modern coherent dark UI
const Color kPrimaryColor = Color(0xFFd21947);
const Color kSecondaryColor = Color(0xFF22252d);
const Color kAccentColor = Color(0xFF05ffee);
const Color kGradientStart = Color(0xFF42155b);
const Color kGradientEnd = Color(0xFF20284a);
const Color kBackgroundColor = Color(0xFF15161c);
const Color kCardColor = Color(0xFF22252d);
const double kCardElevation = 10.0;

class AppGradients {
  static LinearGradient accentCard = const LinearGradient(
    colors: [kPrimaryColor, kAccentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.1, 0.8],
  );
  static LinearGradient subtleBackground = const LinearGradient(
    colors: [kGradientStart, kGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

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
    final baseTextTheme = ThemeData.dark().textTheme;
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
        appBarTheme: AppBarTheme(
          backgroundColor: kSecondaryColor,
          elevation: 3,
          iconTheme: const IconThemeData(color: kAccentColor),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 0.15,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 12,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) => states.contains(WidgetState.disabled)
                  ? Colors.white12
                  : kPrimaryColor,
            ),
            elevation: WidgetStateProperty.all<double>(8),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
            overlayColor: WidgetStateProperty.all<Color>(kAccentColor.withOpacity(0.08)),
            textStyle: WidgetStateProperty.all<TextStyle>(
              GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
            shadowColor: WidgetStateProperty.all<Color>(kPrimaryColor.withOpacity(0.25)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: kSecondaryColor,
          selectedItemColor: kAccentColor,
          unselectedItemColor: Colors.white54,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 13,
        ),
        cardTheme: CardTheme(
          color: kCardColor,
          elevation: kCardElevation,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          shadowColor: kPrimaryColor.withOpacity(0.18),
        ),
        textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
          displayLarge: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
          displayMedium: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          displaySmall: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
          bodyLarge: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
          bodyMedium: GoogleFonts.inter(
              color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 16),
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

///
/// Handles authentication state & navigation.
///
class _AuthNavigationState extends State<AuthNavigation> {
  bool _isAuthenticated = false;
  bool _showLogin = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = await AuthService.isAuthenticated();
    if (!mounted) return;
    setState(() {
      _isAuthenticated = auth;
    });
  }

  void _onAuthenticated() async {
    await _checkAuth();
    if (!mounted) return;
    // Optionally, after login, you might want to reset navigation if required.
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

  void _onLogout() async {
    await AuthService.logout();
    setState(() {
      _isAuthenticated = false;
      _showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return MainScaffold(onLogout: _onLogout);
    }
    return _showLogin
        ? LoginScreen(
            onLogin: _onAuthenticated,
            onSwitchToRegister: _onSwitchToRegister,
          )
        : RegisterScreen(
            onRegister: _onSwitchToLogin, // after register go to login
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
  final VoidCallback? onLogout;
  const MainScaffold({super.key, this.onLogout});

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
      appBar: AppBar(
        title: const Text('Finance Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kAccentColor),
            tooltip: 'Logout',
            onPressed: widget.onLogout,
          ),
        ],
        backgroundColor: kSecondaryColor,
      ),
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
class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSwitchToRegister;
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSwitchToRegister,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Navigation to dashboard with clearing of stacks, after successful login.
  void _navigateToDashboard(BuildContext navContext) {
    // Replace entire navigation stack with MainScaffold (dashboard)
    Navigator.of(navContext).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => MainScaffold()),
      (Route<dynamic> route) => false,
    );
  }

  // Triggered when user presses Login button
  void _handleLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    Map<String, dynamic> result = {};
    try {
      result = await AuthService.login(_emailCtrl.text.trim(), _pwdCtrl.text);
      if (!mounted) return;
      if (result['success'] == true) {
        _navigateToDashboard(context);
        return;
      }
      setState(() {
        _error = result['message'] ?? 'Login failed';
      });
      // Log unexpected unsuccessful logins for diagnostics
      debugPrint("[LoginScreen] Login failed: ${result['message']}");
    } catch (e, st) {
      debugPrint('[LoginScreen] Uncaught exception during login: $e\n$st');
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred. Please try again.';
        });
        // Optionally, show a dialog here as well
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Login Error'),
            content: Text('$e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

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
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pwdCtrl,
                  obscureText: true,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red))
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : widget.onSwitchToRegister,
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
class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegister;
  final VoidCallback onSwitchToLogin;
  const RegisterScreen({
    super.key,
    required this.onRegister,
    required this.onSwitchToLogin,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  void _handleRegister() async {
    // Start loading and clear messages
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    // Early validation before async
    if (_emailCtrl.text.trim().isEmpty || _pwdCtrl.text.isEmpty) {
      setState(() {
        _error = "Email and password are required.";
        _loading = false;
      });
      return;
    } else if (_pwdCtrl.text != _confirmCtrl.text) {
      setState(() {
        _error = "Passwords do not match.";
        _loading = false;
      });
      return;
    }

    // Await the async registration and after it's done, call onRegister only in sync context
    final didSucceed = await _performRegister();
    if (!mounted) return;
    if (didSucceed) {
      widget.onRegister();
    }
  }

  /// Returns true if registration succeeded (i.e. callback should fire), false otherwise.
  Future<bool> _performRegister() async {
    final result = await AuthService.register(
      _emailCtrl.text.trim(),
      _pwdCtrl.text,
    );
    if (!mounted) return false; // Prevent context/member use after async gap

    final bool didSucceed = result['success'] == true;
    if (!mounted) return false;
    setState(() {
      _loading = false;
      if (didSucceed) {
        _success = result['message'] ?? "Registration successful. Please log in.";
      } else {
        _error = result['message'] ?? "Registration failed.";
      }
    });
    return didSucceed;
  }

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
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pwdCtrl,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmCtrl,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: kSecondaryColor,
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                if (_success != null) ...[
                  const SizedBox(height: 12),
                  Text(_success!, style: const TextStyle(color: Colors.greenAccent)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Register', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading ? null : widget.onSwitchToLogin,
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
///
/// DASHBOARD SCREEN
/// PUBLIC_INTERFACE
/// Modern Dashboard: Shows recent transactions, summary, and interactive access.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecent();
  }

  String? _error;

  Future<void> _fetchRecent() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await TransactionService.fetchTransactions();
      setState(() {
        _transactions = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to fetch transactions.";
      });
    }
  }

  void _goToAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => TransactionEditScreen(onSave: _fetchRecent)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: kSecondaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: _fetchRecent,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(31), blurRadius: 16)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Recent Transactions",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kAccentColor)),
                        const SizedBox(height: 10),
                        if (_transactions.isEmpty)
                          const Padding(
                              padding: EdgeInsets.only(top: 14),
                              child: Text('No transactions', style: TextStyle(color: Colors.white54))),
                        for (final t in _transactions.take(6))
                          TransactionListTile(
                            transaction: t,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => TransactionEditScreen(
                                    transaction: t,
                                    onSave: _fetchRecent,
                                  ),
                                ),
                              );
                            },
                            color: kSecondaryColor,
                          ),
                        const SizedBox(height: 6),
                        if (_transactions.length > 6)
                          Text(
                            "... view all in Transactions tab",
                            style: TextStyle(color: kAccentColor, fontSize: 13),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: kSecondaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                      child: Row(
                        children: [
                          Icon(Icons.pie_chart, color: kAccentColor, size: 32),
                          SizedBox(width: 14),
                          Expanded(
                              child: Text(
                                  "Track your spending with interactive charts, see more in Charts tab.",
                                  style: TextStyle(color: Colors.white, fontSize: 16))),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTransaction,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

///
/// TRANSACTIONS SCREEN
/// PUBLIC_INTERFACE
/// Interactive transactions CRUD UI with dark theme.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tx = await TransactionService.fetchTransactions();
      setState(() {
        _transactions = tx;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to fetch transactions.";
      });
    }
  }

  void _goToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => TransactionEditScreen(
          onSave: _fetchTransactions,
        ),
      ),
    );
  }

  // PUBLIC_INTERFACE
  /// Deletes a transaction after user confirmation and refreshes the list.
  Future<void> _deleteTx(int id) async {
    final BuildContext dialogContext = context;
    final confirmed = await showDialog<bool>(
      context: dialogContext,
      builder: (localDialogContext) => AlertDialog(
        backgroundColor: kCardColor,
        title: const Text("Confirm Deletion", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this transaction?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.of(localDialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(localDialogContext).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    // Strict linter appeasement: return unless confirmed and mounted
    if (!mounted || confirmed != true) return;
    await TransactionService.deleteTransaction(id);
    await _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: kSecondaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: _fetchTransactions,
                  child: _transactions.isEmpty
                      ? const Center(child: Text("No transactions yet.", style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                          itemCount: _transactions.length,
                          itemBuilder: (ctx, i) {
                            final t = _transactions[i];
                            return TransactionListTile(
                              transaction: t,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        TransactionEditScreen(transaction: t, onSave: _fetchTransactions),
                                  ),
                                );
                              },
                              onDelete: () async {
                                try {
                                  await _deleteTx(t['id'] as int);
                                } catch (e) {
                                  setState(() {
                                    _error = "Failed to delete transaction.";
                                  });
                                }
                              },
                              color: kCardColor,
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAdd,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// PUBLIC_INTERFACE
// Transaction Create/Edit Screen, shown as modal route for add/edit.
class TransactionEditScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final VoidCallback? onSave;

  const TransactionEditScreen({super.key, this.transaction, this.onSave});

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _categoryCtrl = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descCtrl.text = widget.transaction!['description'] ?? '';
      _amountCtrl.text = widget.transaction!['amount'].toString();
      _categoryCtrl.text = widget.transaction!['category'] ?? '';
      _selectedDate = DateTime.tryParse(widget.transaction!['date'] ?? '');
    } else {
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final double amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final payload = {
      "description": _descCtrl.text.trim(),
      "amount": amount,
      "category": _categoryCtrl.text.trim(),
      "date": _selectedDate?.toIso8601String(),
    };

    bool didSucceed = false;
    if (widget.transaction == null || widget.transaction!['id'] == null) {
      // Create
      final resp = await TransactionService.createTransaction(payload);
      didSucceed = resp != null;
    } else {
      // Update
      final resp =
          await TransactionService.updateTransaction(widget.transaction!['id'], payload);
      didSucceed = resp != null;
    }

    setState(() => _loading = false);

    if (didSucceed) {
      widget.onSave?.call();
      Navigator.of(context).pop();
    } else {
      setState(() => _error = "Failed to save. Try again.");
    }
  }

  Future<void> _pickDate() async {
    // Store context in local variable to avoid use_build_context_synchronously lint
    final localContext = context;
    final picked = await showDatePicker(
      context: localContext,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
      builder: (dialogContext, child) => Theme(
        data: ThemeData.dark().copyWith(
          dialogTheme: const DialogTheme(
            backgroundColor: kCardColor,
          ),
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryColor,
            surface: kCardColor,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null && widget.transaction!['id'] != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: kSecondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: kAccentColor),
                  fillColor: kSecondaryColor,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _amountCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(
                  labelText: "Amount",
                  labelStyle: TextStyle(color: kAccentColor),
                  fillColor: kSecondaryColor,
                  filled: true,
                  border: OutlineInputBorder(),
                  prefixText: "\$ ",
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : double.tryParse(v) == null
                        ? "Not a valid amount"
                        : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _categoryCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Category",
                  labelStyle: TextStyle(color: kAccentColor),
                  fillColor: kSecondaryColor,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 18),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Date",
                  labelStyle: TextStyle(color: kAccentColor),
                  filled: true,
                  fillColor: kSecondaryColor,
                  border: OutlineInputBorder(),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
                        : "Pick a date",
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.date_range, color: kPrimaryColor),
                    onPressed: _loading ? null : _pickDate,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: Icon(isEdit ? Icons.save : Icons.add, color: Colors.white),
                label: Text(isEdit ? 'Update Transaction' : 'Add Transaction'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// BUDGETS SCREEN
/// PUBLIC_INTERFACE
/// Shows categorized budgets and their spending.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  List<Map<String, dynamic>> _budgets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final b = await BudgetService.fetchBudgets();
      setState(() {
        _budgets = b;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to fetch budgets.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: kSecondaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: _fetchBudgets,
                  child: ListView(
                    children: [
                      const SizedBox(height: 12),
                      ..._budgets.map(
                        (b) => BudgetCard(
                          category: b['category'] ?? "",
                          spent: (b['spent'] ?? 0).toDouble(),
                          limit: (b['limit'] ?? 1).toDouble(),
                          color: kCardColor,
                        ),
                      ),
                      if (_budgets.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: Text("No budgets; Contact admin to set budgets.", style: TextStyle(color: Colors.white38))),
                        ),
                    ],
                  ),
                ),
    );
  }
}

///
/// CHARTS SCREEN
/// PUBLIC_INTERFACE
/// Analytics: Spending categories with stylized charts.
class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});
  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  Map<String, dynamic> _analytics = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final a = await BudgetService.fetchAnalytics();
      setState(() {
        _analytics = a;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Failed to load analytics.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals =
        (_analytics['category_totals'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ??
            {};
    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts & Analytics'),
        backgroundColor: kSecondaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccentColor))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : RefreshIndicator(
                  color: kAccentColor,
                  onRefresh: _fetchAnalytics,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        color: kCardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Spending Breakdown by Category",
                                style:
                                    TextStyle(color: kAccentColor, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 15),
                              if (categoryTotals.isNotEmpty)
                                SpendingPieChart(
                                  categoryData: categoryTotals,
                                )
                              else
                                const Text("No analytics data yet.",
                                    style: TextStyle(color: Colors.white38, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        color: kSecondaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
                          child: Text(
                            "Visualize your monthly and categorical spending! Add transactions with category labels to see them analyzed here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: kAccentColor, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
