import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../utilities/token_storage.dart';
import '../models/analytics.dart';

const String _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

/// Fetch budget analytics (overall and by category) from backend.
/// Endpoint: /analytics/budget
// PUBLIC_INTERFACE
final budgetAnalyticsProvider = FutureProvider<BudgetAnalytics>((ref) async {
  final token = await TokenStorage.getToken();
  final url = Uri.parse('$_baseUrl/analytics/budget');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final res = await http.get(url, headers: headers);
  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);
    return BudgetAnalytics.fromJson(decoded);
  } else {
    throw Exception(res.body.isNotEmpty
        ? (jsonDecode(res.body)['detail']?.toString() ?? "Failed")
        : "Failed to fetch budget analytics");
  }
});

/// Fetch category summary ("spending per category") from backend.
/// Endpoint: /categories/summary
// PUBLIC_INTERFACE
final categorySummaryProvider = FutureProvider<List<CategorySummaryItem>>((ref) async {
  final token = await TokenStorage.getToken();
  final url = Uri.parse('$_baseUrl/categories/summary');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final res = await http.get(url, headers: headers);
  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);
    return (decoded['categories'] as List)
        .map((e) => CategorySummaryItem.fromJson(e))
        .toList();
  } else {
    throw Exception(res.body.isNotEmpty
        ? (jsonDecode(res.body)['detail']?.toString() ?? "Failed")
        : "Failed to fetch category summary");
  }
});
