import 'package:flutter/foundation.dart';

/// Transaction model representing a financial transaction item.
class TransactionModel {
  final String id;
  final double amount;
  final String currency;
  final String category;
  final String type;
  final DateTime date;
  final String? description;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.category,
    required this.type,
    required this.date,
    this.description,
  });

  /// Factory method to create a TransactionModel from JSON response.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }
}
