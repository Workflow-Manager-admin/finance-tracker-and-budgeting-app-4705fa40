import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                    Text('Register', style: Theme.of(context).textTheme.headlineSmall),
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
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                _formKey.currentState?.save();
                                if (_formKey.currentState?.validate() ?? false) {
                                  final success =
                                      await authProvider.register(_username, _password);
                                  if (!success) {
                                    setState(() => _error = 'Failed to register');
                                  } else {
                                    setState(() => _error = null);
                                    Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
                                  }
                                }
                              },
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                        child: const Text('Already registered? Login here'))
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
