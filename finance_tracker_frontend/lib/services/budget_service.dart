import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// PUBLIC_INTERFACE
/// Service for managing budgets and analytics.
class BudgetService {
  static const String apiBaseUrl = AuthService.apiBaseUrl;

  /// PUBLIC_INTERFACE
  /// Fetches budgets for authenticated user.
  static Future<List<Map<String, dynamic>>> fetchBudgets() async {
    final url = Uri.parse('$apiBaseUrl/budgets');
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
  /// Fetch spending analytics (e.g., per category breakdowns).
  static Future<Map<String, dynamic>> fetchAnalytics() async {
    final url = Uri.parse('$apiBaseUrl/analytics/spending');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";
    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    return {};
  }

  // PUBLIC_INTERFACE
  /// Creates a new budget. Returns response map on success, else error/validation detail.
  /// form: { limit, period, start_date, end_date, category_name }
  static Future<Map<String, dynamic>?> createBudget(Map<String, dynamic> data) async {
    final url = Uri.parse('$apiBaseUrl/budgets/');
    final headers = await AuthService.getAuthHeader();
    headers["Content-Type"] = "application/json";

    int? categoryId;
    if (data.containsKey("category_name") && data["category_name"] != null && (data["category_name"] as String).trim().isNotEmpty) {
      // Try to resolve category (reuse logic from transaction service)
      try {
        final catUrl = Uri.parse('$apiBaseUrl/categories/');
        final resp = await http.get(catUrl, headers: headers);
        if (resp.statusCode == 200) {
          final List cats = json.decode(resp.body);
          final found = cats.firstWhere(
            (c) => c is Map && (c["name"] as String).trim().toLowerCase() == (data["category_name"] as String).trim().toLowerCase(),
            orElse: () => null,
          );
          if (found != null && found["id"] != null) categoryId = found["id"] as int;
        }
        if (categoryId == null) {
          // Create new category if it doesn't exist
          final createResp = await http.post(catUrl,
              headers: headers, body: json.encode({"name": data["category_name"]}));
          if (createResp.statusCode == 200 || createResp.statusCode == 201) {
            final d = json.decode(createResp.body);
            categoryId = d["id"] as int?;
          }
        }
      } catch (_) {}
    }

    final backendPayload = {
      "limit": data["limit"],
      "period": data["period"], // e.g. "monthly"
      "start_date": data["start_date"], // ISO8601 string
      "end_date": data["end_date"], // ISO8601 string or null
      "category_id": categoryId // may be null (for general budgets)
    };

    try {
      final resp = await http.post(url, headers: headers, body: json.encode(backendPayload));
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        return json.decode(resp.body) as Map<String, dynamic>;
      } else if (resp.body.isNotEmpty) {
        // Return error detail for UI
        try {
          return json.decode(resp.body) as Map<String, dynamic>;
        } catch (_) {}
      }
    } catch (_) {}
    return null;
  }
}
