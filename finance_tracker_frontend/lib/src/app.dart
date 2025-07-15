import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transaction_crud_screen.dart';

/// Root widget for the finance tracker application.
class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<TransactionProvider>(
            create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          DashboardScreen.routeName: (_) => const DashboardScreen(),
          TransactionCrudScreen.routeName: (_) =>
              const TransactionCrudScreen(),
        },
      ),
    );
  }
}
