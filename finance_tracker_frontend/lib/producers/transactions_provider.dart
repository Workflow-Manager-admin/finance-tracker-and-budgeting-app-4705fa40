import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/transaction.dart';
import '../utilities/token_storage.dart';

/// Holds state for a list of transactions (supports pagination).
class TransactionsListState {
  final List<TransactionModel>? transactions;
  final int total;
  final bool isLoading;
  final String? error;

  TransactionsListState({
    this.transactions,
    this.total = 0,
    this.isLoading = false,
    this.error,
  });

  TransactionsListState copyWith({
    List<TransactionModel>? transactions,
    int? total,
    bool? isLoading,
    String? error,
  }) {
    return TransactionsListState(
      transactions: transactions ?? this.transactions,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory TransactionsListState.initial() =>
      TransactionsListState(transactions: null, isLoading: false, error: null, total: 0);
}

/// Helper for consistent base URL.
const String _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

/// Retrieves all user transactions (optionally paginated).
// PUBLIC_INTERFACE
final transactionsListProvider = FutureProvider.autoDispose
    .family<List<TransactionModel>, Map<String, int>?>((ref, params) async {
  final token = await TokenStorage.getToken();
  final limit = params?['limit'] ?? 20;
  final offset = params?['offset'] ?? 0;
  final url = Uri.parse('$_baseUrl/transactions?limit=$limit&offset=$offset');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  final res = await http.get(url, headers: headers);
  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);
    final txs = (decoded['transactions'] as List?)
        ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? <TransactionModel>[];
    // Not using total in this minimal provider; could be extended to support infinite scroll/pagination UI
    return txs;
  } else {
    throw Exception(res.body.isNotEmpty
        ? (jsonDecode(res.body)['detail']?.toString() ?? "Failed")
        : "Failed to fetch data");
  }
});

// PUBLIC_INTERFACE
final transactionDetailProvider =
    FutureProvider.autoDispose.family<TransactionModel, String>((ref, id) async {
  final token = await TokenStorage.getToken();
  final url = Uri.parse('$_baseUrl/transactions/$id');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };
  final res = await http.get(url, headers: headers);
  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);
    return TransactionModel.fromJson(decoded);
  } else {
    throw Exception(res.body.isNotEmpty
        ? (jsonDecode(res.body)['detail']?.toString() ?? "Failed")
        : "Failed to fetch.");
  }
});

/// Create, update, and delete are handled by direct async notifier for state management.
class TransactionCrudState {
  final bool isLoading;
  final String? error;
  final bool success;

  TransactionCrudState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  TransactionCrudState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return TransactionCrudState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }

  factory TransactionCrudState.initial() =>
      TransactionCrudState(isLoading: false, error: null, success: false);
}

class TransactionCrudNotifier extends StateNotifier<TransactionCrudState> {
  TransactionCrudNotifier() : super(TransactionCrudState.initial());

  // PUBLIC_INTERFACE
  /// Create new transaction (POST /transactions)
  Future<bool> create(Map<String, dynamic> payload) async {
    state = TransactionCrudState(isLoading: true);
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse('$_baseUrl/transactions');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final res = await http.post(url, headers: headers, body: jsonEncode(payload));
      if (res.statusCode == 201) {
        state = TransactionCrudState(isLoading: false, success: true);
        return true;
      } else {
        String errorMsg = "Failed to create transaction.";
        try {
          if (res.body.isNotEmpty) {
            errorMsg = jsonDecode(res.body)['detail']?.toString() ?? errorMsg;
          }
        } catch (_) {}
        state = state.copyWith(isLoading: false, error: errorMsg, success: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), success: false);
      return false;
    }
  }

  // PUBLIC_INTERFACE
  /// Edit transaction (PUT /transactions/{id})
  Future<bool> update(String id, Map<String, dynamic> payload) async {
    state = TransactionCrudState(isLoading: true);
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse('$_baseUrl/transactions/$id');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final res = await http.put(url, headers: headers, body: jsonEncode(payload));
      if (res.statusCode == 200) {
        state = TransactionCrudState(isLoading: false, success: true);
        return true;
      } else {
        String errorMsg = "Failed to update transaction.";
        try {
          if (res.body.isNotEmpty) {
            errorMsg = jsonDecode(res.body)['detail']?.toString() ?? errorMsg;
          }
        } catch (_) {}
        state = state.copyWith(isLoading: false, error: errorMsg, success: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), success: false);
      return false;
    }
  }

  // PUBLIC_INTERFACE
  /// Delete transaction (DELETE /transactions/{id})
  Future<bool> delete(String id) async {
    state = TransactionCrudState(isLoading: true);
    try {
      final token = await TokenStorage.getToken();
      final url = Uri.parse('$_baseUrl/transactions/$id');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final res = await http.delete(url, headers: headers);
      if (res.statusCode == 204) {
        state = TransactionCrudState(isLoading: false, success: true);
        return true;
      } else {
        String errorMsg = "Failed to delete transaction.";
        try {
          if (res.body.isNotEmpty) {
            errorMsg = jsonDecode(res.body)['detail']?.toString() ?? errorMsg;
          }
        } catch (_) {}
        state = state.copyWith(isLoading: false, error: errorMsg, success: false);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), success: false);
      return false;
    }
  }

  // Reset state for UI
  void reset() {
    state = TransactionCrudState.initial();
  }
}

// PUBLIC_INTERFACE
final transactionCrudProvider =
    StateNotifierProvider<TransactionCrudNotifier, TransactionCrudState>((ref) {
  return TransactionCrudNotifier();
});
