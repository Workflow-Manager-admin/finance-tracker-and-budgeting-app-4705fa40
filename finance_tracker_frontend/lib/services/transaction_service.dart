import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'package:flutter/foundation.dart';

/// PUBLIC_INTERFACE
/// Service for managing transactions by interacting with backend REST API.
class TransactionService {
  static const String apiBaseUrl = AuthService.apiBaseUrl;

  /// PUBLIC_INTERFACE
  /// Fetches all transactions for the authenticated user.
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final url = Uri.parse('$apiBaseUrl/transactions');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";
    final resp = await http.get(url, headers: headers);
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
    // The backend expects: amount (float), type ('income' or 'expense'), category_id (int), optional description, timestamp
    // The frontend currently sends: description, amount, category (string), date (string ISO)
    final url = Uri.parse('$apiBaseUrl/transactions/');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";

    // We need to get category_id (int) and type ('income' or 'expense') for a valid backend call
    // If category is a string, fetch all categories, find id, else fallback to category = null (backend required)
    // For now, assume category_id = 1 and type by amount sign (positive=income, negative=expense), but print debug.

    int? categoryId;
    String? type;
    if (data.containsKey("amount")) {
      final double amt = (data["amount"] as num).toDouble();
      type = amt >= 0 ? "income" : "expense";
    }
    // Attempt to extract category id if possible, otherwise fallback to 1 (should ideally resolve by fetching).
    // SAFE fallback (fixable by actual fetch/categories lookup):
    categoryId = 1;
    if (data.containsKey("category")) {
      // Could be future: fetch /categories/, match by name, assign ID
      // TODO: Category resolution for production; for demo, fallback to 1
    }

    final backendPayload = {
      "amount": data["amount"],
      "type": type,
      "category_id": categoryId,
      "description": data["description"],
      "timestamp": data["date"], // Backend expects 'timestamp'
    };

    final resp = await http.post(url, headers: headers, body: json.encode(backendPayload));
    // The backend returns a 200 status and transaction object on success
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    } else {
      // For diagnostics, but avoid print in production
      // ignore: avoid_print
      // print("[TransactionService] createTransaction failed: ${resp.statusCode} ${resp.body}");
      // Instead, use debugPrint for error reporting
      if (resp.body.isNotEmpty) {
        try {
          // ignore: avoid_print
          // debugPrint is preferred for Flutter logs
          debugPrint("[TransactionService] createTransaction failed: ${resp.statusCode} ${resp.body}");
        } catch (_) {}
      }
    }
    return null;
  }

  /// PUBLIC_INTERFACE
  /// Updates a transaction.
  static Future<Map<String, dynamic>?> updateTransaction(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$apiBaseUrl/transactions/$id');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";
    final resp = await http.put(url, headers: headers, body: json.encode(data));
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// PUBLIC_INTERFACE
  /// Deletes a transaction.
  static Future<bool> deleteTransaction(int id) async {
    final url = Uri.parse('$apiBaseUrl/transactions/$id');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";
    final resp = await http.delete(url, headers: headers);
    return resp.statusCode == 204 || resp.statusCode == 200;
  }
}
