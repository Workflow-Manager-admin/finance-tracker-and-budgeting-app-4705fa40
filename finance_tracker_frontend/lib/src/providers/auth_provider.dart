import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// AuthProvider handles user authentication state and JWT-based API calls.
class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _username;
  bool _loading = false;

  String? get token => _token;
  String? get username => _username;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _loading;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    final url = Uri.parse("${dotenv.env['BACKEND_BASE_URL'] ?? ''}/auth/login");
    final response = await http.post(url, body: {
      'username': username,
      'password': password,
    });
    _setLoading(false);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
      if (_token != null) {
        _username = JwtDecoder.decode(_token!)['sub'] ?? username;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // PUBLIC_INTERFACE
  Future<bool> register(String username, String password) async {
    _setLoading(true);
    final url = Uri.parse("${dotenv.env['BACKEND_BASE_URL'] ?? ''}/auth/register");
    final response = await http.post(url, body: {
      'username': username,
      'password': password,
    });
    _setLoading(false);
    if (response.statusCode == 201) {
      return await login(username, password);
    }
    return false;
  }

  // PUBLIC_INTERFACE
  void logout() {
    _token = null;
    _username = null;
    notifyListeners();
  }
}
