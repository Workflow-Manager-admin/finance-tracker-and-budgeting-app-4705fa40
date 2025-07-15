import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

/// TransactionProvider manages fetching, creating, updating, and deleting transactions.
class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // PUBLIC_INTERFACE
  Future<void> fetchTransactions({required String token}) async {
    _isLoading = true;
    notifyListeners();
    final url = Uri.parse("${dotenv.env['BACKEND_BASE_URL']}/transactions");
    final headers = {'Authorization': "Bearer $token"};
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) ?? [];
      _transactions = jsonList
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    }
    _isLoading = false;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<bool> addTransaction(
      {required String token, required TransactionModel tx}) async {
    final url = Uri.parse("${dotenv.env['BACKEND_BASE_URL']}/transactions");
    final headers = {
      'Authorization': "Bearer $token",
      'Content-Type': 'application/json'
    };
    final response = await http.post(url, headers: headers, body: jsonEncode(tx.toJson()));
    if (response.statusCode == 201) {
      await fetchTransactions(token: token);
      return true;
    }
    return false;
  }

  // PUBLIC_INTERFACE
  Future<bool> updateTransaction(
      {required String token, required TransactionModel tx}) async {
    final url = Uri.parse("${dotenv.env['BACKEND_BASE_URL']}/transactions/${tx.id}");
    final headers = {
      'Authorization': "Bearer $token",
      'Content-Type': 'application/json'
    };
    final response =
        await http.put(url, headers: headers, body: jsonEncode(tx.toJson()));
    if (response.statusCode == 200) {
      await fetchTransactions(token: token);
      return true;
    }
    return false;
  }

  // PUBLIC_INTERFACE
  Future<bool> deleteTransaction(
      {required String token, required int txId}) async {
    final url =
        Uri.parse("${dotenv.env['BACKEND_BASE_URL']}/transactions/$txId");
    final headers = {'Authorization': "Bearer $token"};
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      await fetchTransactions(token: token);
      return true;
    }
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
