class Budget {
  const Budget({
    required this.id,
    required this.name,
    required this.amount,
    required this.spent,
    required this.period,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double amount;
  final double spent;
  final BudgetPeriod period;
  final DateTime createdAt;

  double get progress => amount <= 0 ? 0 : (spent / amount).clamp(0, 1);
  bool get isExceeded => spent > amount;

  Budget copyWith({double? spent}) => Budget(
        id: id,
        name: name,
        amount: amount,
        spent: spent ?? this.spent,
        period: period,
        createdAt: createdAt,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'amount': amount,
        'spent': spent,
        'period': period.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Budget.fromJson(Map<String, Object?> json) => Budget(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        spent: (json['spent'] as num).toDouble(),
        period: BudgetPeriod.values.byName(json['period'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

enum BudgetPeriod { weekly, monthly }
