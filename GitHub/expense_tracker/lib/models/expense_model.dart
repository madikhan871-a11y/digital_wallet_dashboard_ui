class ExpenseModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'Other',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      isIncome: json['is_income'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'is_income': isIncome,
      'user_id': userId,
    };
  }
}
