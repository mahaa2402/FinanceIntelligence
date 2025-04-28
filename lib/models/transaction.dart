enum TransactionType {
  income,
  expense,
}

enum TransactionCategory {
  food,
  transportation,
  entertainment,
  shopping,
  utilities,
  health,
  education,
  housing,
  travel,
  salary,
  investment,
  other,
}

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  // Convert Transaction object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'description': description,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Transaction object from a map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: _parseTransactionType(map['type'] ?? 'expense'),
      category: _parseTransactionCategory(map['category'] ?? 'other'),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Helper method to get category icon name
  String get categoryIconName {
    switch (category) {
      case TransactionCategory.food:
        return 'restaurant';
      case TransactionCategory.transportation:
        return 'directions_car';
      case TransactionCategory.entertainment:
        return 'movie';
      case TransactionCategory.shopping:
        return 'shopping_bag';
      case TransactionCategory.utilities:
        return 'tungsten';
      case TransactionCategory.health:
        return 'healing';
      case TransactionCategory.education:
        return 'school';
      case TransactionCategory.housing:
        return 'home';
      case TransactionCategory.travel:
        return 'flight';
      case TransactionCategory.salary:
        return 'account_balance_wallet';
      case TransactionCategory.investment:
        return 'trending_up';
      case TransactionCategory.other:
        return 'more_horiz';
    }
  }
}

// Helper function to parse transaction type from string
TransactionType _parseTransactionType(String typeStr) {
  return TransactionType.values.firstWhere(
    (e) => e.toString().split('.').last == typeStr,
    orElse: () => TransactionType.expense,
  );
}

// Helper function to parse transaction category from string
TransactionCategory _parseTransactionCategory(String categoryStr) {
  return TransactionCategory.values.firstWhere(
    (e) => e.toString().split('.').last == categoryStr,
    orElse: () => TransactionCategory.other,
  );
}
