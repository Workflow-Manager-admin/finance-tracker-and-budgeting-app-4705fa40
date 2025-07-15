import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// PUBLIC_INTERFACE
/// AuthService handles registration, login, JWT storage, and token fetch for API requests.
class AuthService {
  // Instance for secure storage
  static const _storage = FlutterSecureStorage();

  // Update this to your current ngrok/public backend base URL:
  // IMPORTANT: Set this to the currently exposed backend API. Update when ngrok restarts!
  static const String apiBaseUrl = "https://02f0de475628.ngrok-free.app";

  // -- NETWORK DEBUG INFO (Not part of build; for dev diagnostics only) --
  // Backend running location: https://02f0de475628.ngrok-free.app
  // apiBaseUrl above is set to: https://02f0de475628.ngrok-free.app
  // For Android emulator:       http://10.0.2.2:<PORT> (maps to localhost on dev machine)
  // For iOS simulator:          http://localhost:<PORT> (physical device: use LAN IP or tunneled URL)
  // To match backend, set      apiBaseUrl to: https://02f0de475628.ngrok-free.app
  // Example registration URL:  https://02f0de475628.ngrok-free.app/auth/register
  // Example health check:      https://02f0de475628.ngrok-free.app/
  //

  /// PUBLIC_INTERFACE
  /// Attempts user login with API.
  /// Returns: { "success": true, "message": "..."} on success, or {"success": false, "message": "..."} on failure.
  /// On success, saves access_token in secure storage for future requests.
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Backend expects JSON body: {email, password}
    final url = Uri.parse("$apiBaseUrl/auth/login");
    final body = json.encode({"email": email, "password": password});

    String friendlyError(dynamic v) {
      // Robustly convert error message/list/other to user-facing string
      if (v == null) return "Login failed.";
      if (v is String) return v;
      if (v is List) return v.map((item) => friendlyError(item)).join('\n');
      if (v is Map && v.containsKey('msg')) {
        // fastapi validation error items
        return v['msg'].toString();
      }
      return v.toString();
    }

    try {
      final resp = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 12));

      // Expect 200 and an access_token in the response body
      if (resp.statusCode == 200) {
        try {
          final data = json.decode(resp.body);
          if (data['access_token'] != null) {
            await _setJwtToken(data['access_token']);
            debugPrint("[AuthService] Login successful, JWT stored.");
            return {"success": true, "message": "Login successful."};
          } else if (data['detail'] != null) {
            debugPrint("[AuthService] Login failed: ${data['detail']}");
            return {
              "success": false,
              "message": friendlyError(data['detail'])
            };
          }
          debugPrint("[AuthService] Login malformed response: $data");
          return {"success": false, "message": "Malformed response from server."};
        } catch (e) {
          debugPrint("[AuthService] Login parse error: $e");
          return {"success": false, "message": "Failed to parse server response."};
        }
      } else if (resp.statusCode == 401) {
        // Unauthorized (bad credentials)
        debugPrint("[AuthService] Login 401 Unauthorized: Invalid credentials.");
        return {"success": false, "message": "Invalid credentials."};
      } else {
        // Try to get error details from server if available
        try {
          final err = json.decode(resp.body);
          debugPrint("[AuthService] Login error: $err");
          dynamic errDetail = err['detail'] ?? err['error'] ?? err;
          return {
            "success": false,
            "message": friendlyError(errDetail)
          };
        } catch (ex) {
          debugPrint("[AuthService] Login (bad server error response): $ex, status: ${resp.statusCode}");
          return {"success": false, "message": "Invalid credentials or server error."};
        }
      }
    } on TimeoutException catch (tmo) {
      debugPrint("[AuthService] Login timed out: $tmo");
      return {"success": false, "message": "Request timed out. Please try again."};
    } on http.ClientException catch (e) {
      debugPrint("[AuthService] Network error: ${e.message}");
      return {"success": false, "message": "Network error: ${e.message}"};
    } catch (e, st) {
      debugPrint('[AuthService] Unexpected error: $e\n$st');
      return {"success": false, "message": "An unexpected error occurred: $e"};
    }
  }

  /// PUBLIC_INTERFACE
  /// Attempts user registration, returns true if successful, false otherwise.
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final url = Uri.parse("$apiBaseUrl/auth/register");
    final body = json.encode({"email": email, "password": password});
    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body)
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return {"success": true, "message": "Registration successful. Please log in."};
      } else {
        try {
          final data = json.decode(resp.body);
          return {"success": false, "message": data['detail'] ?? "Unknown error."};
        } catch (_) {
          return {"success": false, "message": "Registration failed."};
        }
      }
    } on http.ClientException catch (e) {
      return {"success": false, "message": "Network error: ${e.message}"};
    } on TimeoutException {
      return {"success": false, "message": "Request timed out. Please try again."};
    } catch (e) {
      return {"success": false, "message": "An unexpected error occurred: $e"};
    }
  }

  /// Returns true if token is stored (user is authenticated), else false.
  static Future<bool> isAuthenticated() async {
    final token = await _getJwtToken();
    return token != null && token.isNotEmpty;
  }

  /// Logs user out (deletes JWT token).
  static Future<void> logout() async {
    await _storage.delete(key: "jwt_token");
  }

  /// Fetch JWT token from secure storage.
  static Future<String?> getJwtToken() async {
    return await _getJwtToken();
  }

  // Helper: store JWT token securely.
  static Future<void> _setJwtToken(String token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

  // Helper: get JWT from secure storage.
  static Future<String?> _getJwtToken() async {
    return await _storage.read(key: "jwt_token");
  }

  /// PUBLIC_INTERFACE
  /// Get Authorization header for authenticated requests.
  /// Usage: pass as part of headers in backend calls.
  static Future<Map<String, String>> getAuthHeader() async {
    final token = await _getJwtToken();
    if (token != null && token.isNotEmpty) {
      return {"Authorization": "Bearer $token"};
    }
    return {};
  }
}
