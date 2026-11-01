import 'package:expense_iq/core/models/budget.dart';
import 'package:expense_iq/core/models/savings_goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('budget progress is clamped', () {
    final budget = Budget(
      id: 'b1',
      name: 'Food',
      amount: 100,
      spent: 160,
      period: BudgetPeriod.monthly,
      createdAt: DateTime(2026),
    );

    expect(budget.progress, 1);
    expect(budget.isExceeded, isTrue);
  });

  test('savings goal detects completion', () {
    final goal = SavingsGoal(
      id: 'g1',
      name: 'Emergency',
      targetAmount: 1000,
      savedAmount: 1000,
      targetDate: DateTime(2026),
    );

    expect(goal.isComplete, isTrue);
    expect(goal.progress, 1);
  });
}
