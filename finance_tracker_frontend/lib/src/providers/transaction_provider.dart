import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/network_helper.dart';

/// TransactionProvider manages fetching, creating, updating, and deleting transactions.
class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMsg;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;

  void clearError() {
    _errorMsg = null;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<void> fetchTransactions({required String token}) async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();
    try {
      final response = await NetworkHelper.sendRequest(
        "/transactions",
        method: "GET",
        authenticated: true,
        token: token,
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) ?? [];
        _transactions = jsonList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else {
        _errorMsg = NetworkHelper.extractApiError(response.body);
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> addTransaction(
      {required String token, required TransactionModel tx}) async {
    _errorMsg = null;
    try {
      final response = await NetworkHelper.sendRequest(
        "/transactions",
        method: "POST",
        body: jsonEncode(tx.toJson()),
        headers: {"Content-Type": "application/json"},
        authenticated: true,
        token: token,
      );
      if (response.statusCode == 201) {
        await fetchTransactions(token: token);
        return true;
      } else {
        _errorMsg = NetworkHelper.extractApiError(response.body);
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    notifyListeners();
    return false;
  }

  // PUBLIC_INTERFACE
  Future<bool> updateTransaction(
      {required String token, required TransactionModel tx}) async {
    _errorMsg = null;
    try {
      final response = await NetworkHelper.sendRequest(
        "/transactions/${tx.id}",
        method: "PUT",
        body: jsonEncode(tx.toJson()),
        headers: {"Content-Type": "application/json"},
        authenticated: true,
        token: token,
      );
      if (response.statusCode == 200) {
        await fetchTransactions(token: token);
        return true;
      } else {
        _errorMsg = NetworkHelper.extractApiError(response.body);
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    notifyListeners();
    return false;
  }

  // PUBLIC_INTERFACE
  Future<bool> deleteTransaction(
      {required String token, required int txId}) async {
    _errorMsg = null;
    try {
      final response = await NetworkHelper.sendRequest(
        "/transactions/$txId",
        method: "DELETE",
        authenticated: true,
        token: token,
      );
      if (response.statusCode == 200) {
        await fetchTransactions(token: token);
        return true;
      } else {
        _errorMsg = NetworkHelper.extractApiError(response.body);
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    notifyListeners();
    return false;
  }

  // PUBLIC_INTERFACE
  Map<String, double> categoryTotals() {
    final Map<String, double> totals = {};
    for (final tx in _transactions) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }
    return totals;
  }
}
