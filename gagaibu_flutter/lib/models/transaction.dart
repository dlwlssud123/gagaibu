enum TransactionType { INCOME, EXPENDITURE }

class Transaction {
  final int? id;
  final int userId;
  final int amount;
  final String category;
  final String? subCategory;
  final String content;
  final String transactionDate; // YYYY-MM-DD format
  final TransactionType transactionType;

  Transaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    this.subCategory,
    required this.content,
    required this.transactionDate,
    required this.transactionType,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      userId: json['userId'] as int,
      amount: json['amount'] as int,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      content: json['content'] as String,
      transactionDate: json['transactionDate'] as String,
      transactionType: json['transactionType'] == 'INCOME'
          ? TransactionType.INCOME
          : TransactionType.EXPENDITURE,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'amount': amount,
      'category': category,
      if (subCategory != null) 'subCategory': subCategory,
      'content': content,
      'transactionDate': transactionDate,
      'transactionType': transactionType == TransactionType.INCOME ? 'INCOME' : 'EXPENDITURE',
    };
  }
}
