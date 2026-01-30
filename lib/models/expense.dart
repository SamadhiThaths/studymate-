class Expense {
  String id;
  String category;
  double amount;
  String? description;
  DateTime date;
  DateTime createdAt;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  // Convert Expense to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Expense from Map (from database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy of Expense with some fields changed
  Expense copyWith({
    String? id,
    String? category,
    double? amount,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}