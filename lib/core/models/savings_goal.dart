class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;

  double get progress =>
      targetAmount <= 0 ? 0 : (savedAmount / targetAmount).clamp(0, 1);
  bool get isComplete => savedAmount >= targetAmount;

  SavingsGoal copyWith({double? savedAmount}) => SavingsGoal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        targetDate: targetDate,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'targetDate': targetDate.toIso8601String(),
      };

  factory SavingsGoal.fromJson(Map<String, Object?> json) => SavingsGoal(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        savedAmount: (json['savedAmount'] as num).toDouble(),
        targetDate: DateTime.parse(json['targetDate'] as String),
      );
}
