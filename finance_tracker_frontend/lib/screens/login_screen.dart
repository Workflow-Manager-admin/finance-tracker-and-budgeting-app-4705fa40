import 'package:flutter/material.dart';
import '../widgets/error_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../producers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AppErrorWidget(message: auth.error!),
                        ),
                      TextFormField(
                        enabled: !auth.isLoading,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: 'Username',
                        ),
                        onChanged: (value) => _username = value,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        enabled: !auth.isLoading,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) => _password = value,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() == true) {
                                  await ref
                                      .read(authProvider.notifier)
                                      .login(_username, _password);
                                }
                              },
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Login'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterScreen()));
                              },
                        child: const Text('Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
