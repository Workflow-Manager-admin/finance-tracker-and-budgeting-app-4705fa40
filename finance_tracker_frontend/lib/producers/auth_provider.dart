import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../utilities/token_storage.dart';
import '../utilities/api_constants.dart';

/// Auth states for login/register flows.
class AuthState {
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    required this.token,
    required this.isLoading,
    required this.error,
    required this.isAuthenticated,
  });

  factory AuthState.initial() => AuthState(
        token: null,
        isLoading: false,
        error: null,
        isAuthenticated: false,
      );

  AuthState copyWith({
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial()) {
    _loadToken();
  }

  // Use centralized API constants for base URL.
  static const String baseUrl = ApiConstants.apiBaseUrl;

  Future<void> _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      state = state.copyWith(isAuthenticated: true, token: token);
    }
  }

  // PUBLIC_INTERFACE
  /// Perform login using backend API and store JWT if successful.
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['access_token'] ?? data['token'];
        if (token != null) {
          await TokenStorage.saveToken(token);
          state = state.copyWith(
            token: token,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'No token received from server.',
            isAuthenticated: false,
          );
        }
      } else {
        final message =
            res.body.isNotEmpty ? jsonDecode(res.body)['detail']?.toString() : 'Login failed';
        state = state.copyWith(isLoading: false, error: message, isAuthenticated: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), isAuthenticated: false);
    }
  }

  // PUBLIC_INTERFACE
  /// Register a new user with backend API.
  Future<void> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (res.statusCode == 201) {
        // Registration success. Optionally try auto-login or update UI.
        await login(username, password);
      } else {
        final message =
            res.body.isNotEmpty ? jsonDecode(res.body)['detail']?.toString() : 'Registration failed';
        state = state.copyWith(isLoading: false, error: message, isAuthenticated: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), isAuthenticated: false);
    }
  }

  // PUBLIC_INTERFACE
  /// Log out the user by discarding token locally.
  Future<void> logout() async {
    await TokenStorage.deleteToken();
    state = AuthState.initial();
  }
}

/// Riverpod provider for authentication state.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
