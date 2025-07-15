import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// PUBLIC_INTERFACE
/// Service for managing transactions by interacting with backend REST API.
class TransactionService {
  static const String apiBaseUrl = AuthService.apiBaseUrl;

  /// PUBLIC_INTERFACE
  /// Fetches all transactions for the authenticated user.
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final token = await AuthService.getJwtToken();
    final url = Uri.parse('$apiBaseUrl/transactions');
    final resp = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    if (resp.statusCode == 200) {
      try {
        final List<dynamic> list = json.decode(resp.body);
        return list.cast<Map<String, dynamic>>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  /// PUBLIC_INTERFACE
  /// Creates a new transaction.
  static Future<Map<String, dynamic>?> createTransaction(Map<String, dynamic> data) async {
    final token = await AuthService.getJwtToken();
    final url = Uri.parse('$apiBaseUrl/transactions');
    final resp = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: json.encode(data),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// PUBLIC_INTERFACE
  /// Updates a transaction.
  static Future<Map<String, dynamic>?> updateTransaction(int id, Map<String, dynamic> data) async {
    final token = await AuthService.getJwtToken();
    final url = Uri.parse('$apiBaseUrl/transactions/$id');
    final resp = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: json.encode(data),
    );
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// PUBLIC_INTERFACE
  /// Deletes a transaction.
  static Future<bool> deleteTransaction(int id) async {
    final token = await AuthService.getJwtToken();
    final url = Uri.parse('$apiBaseUrl/transactions/$id');
    final resp = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );
    return resp.statusCode == 204 || resp.statusCode == 200;
  }
}
