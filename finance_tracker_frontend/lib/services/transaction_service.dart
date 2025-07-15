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
  /// - Resolves category name to category_id (fetches categories or creates if needed)
  /// - Sends correct field names and types according to backend schema
  static Future<Map<String, dynamic>?> createTransaction(Map<String, dynamic> data) async {
    final url = Uri.parse('$apiBaseUrl/transactions/');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";

    // Helper to fetch category_id by name, creating if needed
    Future<int?> resolveCategoryId(String? catName) async {
      if (catName == null || catName.trim().isEmpty) return null;
      final catUrl = Uri.parse('$apiBaseUrl/categories/');
      try {
        // 1. Fetch all categories
        final resp = await http.get(catUrl, headers: headers);
        if (resp.statusCode == 200) {
          final List cats = json.decode(resp.body);
          final found = cats.firstWhere(
            (c) =>
                c is Map &&
                (c["name"] as String).trim().toLowerCase() ==
                    catName.trim().toLowerCase(),
            orElse: () => null,
          );
          if (found != null && found["id"] != null) {
            return found["id"] as int;
          }
        }
        // 2. If not found, try to create
        final newCatResp = await http.post(
          catUrl,
          headers: headers,
          body: json.encode({"name": catName}),
        );
        if (newCatResp.statusCode == 200 || newCatResp.statusCode == 201) {
          final d = json.decode(newCatResp.body);
          return d["id"] as int?;
        }
      } catch (e) {
        debugPrint("[TransactionService] Error resolving category id: $e");
      }
      // fallback
      return null;
    }

    int? categoryId = 1;
    String? type;
    // Compute type from amount
    if (data.containsKey("amount")) {
      final double amt = (data["amount"] as num).toDouble();
      type = amt >= 0 ? "income" : "expense";
    }
    // Try to resolve category_id dynamically and await
    if (data.containsKey("category")) {
      final resolvedId = await resolveCategoryId(data["category"]);
      if (resolvedId != null) {
        categoryId = resolvedId;
      }
    }

    // Rename frontend "date" to "timestamp" for backend
    String? timestamp = data.containsKey("date")
        ? data["date"]
        : (data.containsKey("timestamp") ? data["timestamp"] : null);

    final backendPayload = {
      "amount": data["amount"],
      "type": type,
      "category_id": categoryId,
      "description": data["description"],
      "timestamp": timestamp,
    };

    try {
      final resp = await http.post(url, headers: headers, body: json.encode(backendPayload));

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return json.decode(resp.body) as Map<String, dynamic>;
      } else {
        if (resp.body.isNotEmpty) {
          try {
            debugPrint("[TransactionService] createTransaction failed: ${resp.statusCode} ${resp.body}");
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("[TransactionService] createTransaction: uncaught error $e");
    }
    return null;
  }

  /// PUBLIC_INTERFACE
  /// Updates a transaction.
  static Future<Map<String, dynamic>?> updateTransaction(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$apiBaseUrl/transactions/$id');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";

    // PATCH: Ensure update sends the same mapped fields as creation
    Future<int?> resolveCategoryId(String? catName) async {
      if (catName == null || catName.trim().isEmpty) return null;
      final catUrl = Uri.parse('$apiBaseUrl/categories/');
      try {
        final resp = await http.get(catUrl, headers: headers);
        if (resp.statusCode == 200) {
          final List cats = json.decode(resp.body);
          final found = cats.firstWhere(
            (c) =>
                c is Map &&
                (c["name"] as String).trim().toLowerCase() ==
                    catName.trim().toLowerCase(),
            orElse: () => null,
          );
          if (found != null && found["id"] != null) {
            return found["id"] as int;
          }
        }
        // Try to create category if not found
        final newCatResp = await http.post(
          catUrl,
          headers: headers,
          body: json.encode({"name": catName}),
        );
        if (newCatResp.statusCode == 200 ||
            newCatResp.statusCode == 201) {
          final d = json.decode(newCatResp.body);
          return d["id"] as int?;
        }
      } catch (e) {
        debugPrint("[TransactionService] Error resolving category id (update): $e");
      }
      return null;
    }

    int? categoryId = 1;
    String? type;
    // Compute type from amount
    if (data.containsKey("amount")) {
      final double amt = (data["amount"] as num).toDouble();
      type = amt >= 0 ? "income" : "expense";
    }
    // Resolve category_id if needed
    if (data.containsKey("category")) {
      final resolvedId = await resolveCategoryId(data["category"]);
      if (resolvedId != null) {
        categoryId = resolvedId;
      }
    }

    String? timestamp = data.containsKey("date")
        ? data["date"]
        : (data.containsKey("timestamp") ? data["timestamp"] : null);

    final backendPayload = {
      "amount": data["amount"],
      "type": type,
      "category_id": categoryId,
      "description": data["description"],
      "timestamp": timestamp,
    };

    try {
      final resp = await http.put(url, headers: headers, body: json.encode(backendPayload));
      if (resp.statusCode == 200) {
        return json.decode(resp.body) as Map<String, dynamic>;
      } else {
        if (resp.body.isNotEmpty) {
          try {
            debugPrint("[TransactionService] updateTransaction failed: ${resp.statusCode} ${resp.body}");
            return json.decode(resp.body) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("[TransactionService] updateTransaction: uncaught error $e");
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
