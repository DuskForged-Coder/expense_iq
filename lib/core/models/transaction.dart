enum TransactionType { income, expense }

enum PaymentMethod { cash, card, bankTransfer, wallet, upi }

class ExpenseTransaction {
  const ExpenseTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.notes,
    this.receiptPath,
    this.synced = false,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String notes;
  final String? receiptPath;
  final bool synced;

  ExpenseTransaction copyWith({
    String? title,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? notes,
    String? receiptPath,
    bool? synced,
  }) =>
      ExpenseTransaction(
        id: id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        date: date ?? this.date,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        notes: notes ?? this.notes,
        receiptPath: receiptPath ?? this.receiptPath,
        synced: synced ?? this.synced,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category,
        'date': date.toIso8601String(),
        'paymentMethod': paymentMethod.name,
        'notes': notes,
        'receiptPath': receiptPath,
        'synced': synced,
      };

  factory ExpenseTransaction.fromJson(Map<String, Object?> json) =>
      ExpenseTransaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type'] as String),
        category: json['category'] as String,
        date: DateTime.parse(json['date'] as String),
        paymentMethod:
            PaymentMethod.values.byName(json['paymentMethod'] as String),
        notes: json['notes'] as String? ?? '',
        receiptPath: json['receiptPath'] as String?,
        synced: json['synced'] as bool? ?? false,
      );
}
