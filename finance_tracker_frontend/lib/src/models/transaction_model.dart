class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  // PUBLIC_INTERFACE
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as num),
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }

  // PUBLIC_INTERFACE
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
    };
  }
}
