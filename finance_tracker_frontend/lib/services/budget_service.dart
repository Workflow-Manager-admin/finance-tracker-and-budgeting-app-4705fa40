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
}
