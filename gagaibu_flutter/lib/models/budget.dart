class Budget {
  final int? id;
  final int userId;
  final int amount;
  final int year;
  final int month;

  Budget({
    this.id,
    required this.userId,
    required this.amount,
    required this.year,
    required this.month,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      amount: json['amount'] as int,
      year: json['year'] as int,
      month: json['month'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'amount': amount,
      'year': year,
      'month': month,
    };
  }
}
