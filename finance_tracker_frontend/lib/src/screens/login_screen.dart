import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/error_banner.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SizedBox(
          width: 350,
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authProvider.errorMsg != null)
                      ErrorBanner(
                        message: authProvider.errorMsg ?? "Unknown error",
                        onClose: () => authProvider.clearError(),
                      ),
                    Text('Finance Tracker', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 22),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Username'),
                      onSaved: (val) => _username = val ?? '',
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (val) => _password = val ?? '',
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                _formKey.currentState?.save();
                                if (_formKey.currentState?.validate() ?? false) {
                                  final success = await authProvider.login(_username, _password);
                                  if (success) {
                                    authProvider.clearError();
                                    Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
                                  }
                                }
                              },
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, RegisterScreen.routeName),
                        child: const Text('No account? Register here'))
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
