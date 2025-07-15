import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/network_helper.dart';

/// AuthProvider handles user authentication state and JWT-based API calls.
class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _username;
  bool _loading = false;
  String? _errorMsg;

  String? get token => _token;
  String? get username => _username;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _loading;
  String? get errorMsg => _errorMsg;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMsg = null;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _errorMsg = null;
    try {
      final response = await NetworkHelper.sendRequest(
        "/auth/login",
        method: "POST",
        body: {"username": username, "password": password},
      );
      _setLoading(false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        if (_token != null) {
          _username = JwtDecoder.decode(_token!)['sub'] ?? username;
          notifyListeners();
          return true;
        }
      } else {
        _errorMsg = NetworkHelper.extractApiError(response.body);
      }
    } catch (e) {
      _errorMsg = e.toString();
      _setLoading(false);
      return false;
    }
    return false;
  }

  // PUBLIC_INTERFACE
  Future<bool> register(String username, String password) async {
    _setLoading(true);
    _errorMsg = null;
    try {
      final response = await NetworkHelper.sendRequest(
        "/auth/register",
        method: "POST",
        body: {"username": username, "password": password},
      );
      _setLoading(false);
      if (response.statusCode == 201) {
        return await login(username, password);
      } else {
        _errorMsg = NetworkHelper.extractApiError(response.body);
      }
    } catch (e) {
      _errorMsg = e.toString();
      _setLoading(false);
      return false;
    }
    return false;
  }

  // PUBLIC_INTERFACE
  void logout() {
    _token = null;
    _username = null;
    _errorMsg = null;
    notifyListeners();
  }
}
