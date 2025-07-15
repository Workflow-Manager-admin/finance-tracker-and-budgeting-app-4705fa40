import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../utilities/token_storage.dart';

/// Holds the result of fetching recent dashboard transactions
class DashboardRecentState {
  final List<TransactionModel>? transactions;
  final bool isLoading;
  final String? error;

  DashboardRecentState({
    this.transactions,
    this.isLoading = false,
    this.error,
  });

  DashboardRecentState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return DashboardRecentState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory DashboardRecentState.initial() =>
      DashboardRecentState(transactions: null, isLoading: false, error: null);
}

// PUBLIC_INTERFACE
/// Riverpod provider fetching the most recent dashboard transactions from backend.
final dashboardRecentProvider = FutureProvider<List<TransactionModel>>((ref) async {
  const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  final token = await TokenStorage.getToken();

  final url = Uri.parse('$baseUrl/dashboard/recent?count=5');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  try {
    final res = await http.get(url, headers: headers);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final list = decoded['recent'] as List<dynamic>;
      return list
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        res.body.isNotEmpty ? jsonDecode(res.body)['detail']?.toString() : "Failed to fetch data.",
      );
    }
  } catch (e) {
    throw Exception("Failed to load recent transactions: $e");
  }
});
