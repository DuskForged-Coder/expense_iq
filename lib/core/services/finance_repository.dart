import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expense_iq/core/models/budget.dart';
import 'package:expense_iq/core/models/savings_goal.dart';
import 'package:expense_iq/core/models/transaction.dart';
import 'package:expense_iq/core/services/local_store.dart';
import 'package:uuid/uuid.dart';

class FinanceRepository {
  FinanceRepository(this._localStore, this._connectivity);

  final LocalStore _localStore;
  final Connectivity _connectivity;
  final Uuid _uuid = const Uuid();

  List<ExpenseTransaction> getTransactions() =>
      _localStore.readTransactions().toList();
  List<Budget> getBudgets() => _localStore.readBudgets().toList();
  List<SavingsGoal> getGoals() => _localStore.readGoals().toList();

  Future<void> upsertTransaction(ExpenseTransaction transaction) async {
    final transactions = getTransactions();
    final index = transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      transactions.insert(0, transaction);
    } else {
      transactions[index] = transaction;
    }
    await _localStore.saveTransactions(transactions);
    await _syncTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final transactions =
        getTransactions().where((transaction) => transaction.id != id).toList();
    await _localStore.saveTransactions(transactions);
  }

  ExpenseTransaction createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    required PaymentMethod paymentMethod,
    required String notes,
    String? receiptPath,
  }) =>
      ExpenseTransaction(
        id: _uuid.v4(),
        title: title,
        amount: amount,
        type: type,
        category: category,
        date: date,
        paymentMethod: paymentMethod,
        notes: notes,
        receiptPath: receiptPath,
      );

  Future<void> upsertBudget(Budget budget) async {
    final budgets = getBudgets();
    final index = budgets.indexWhere((item) => item.id == budget.id);
    if (index == -1) {
      budgets.add(budget);
    } else {
      budgets[index] = budget;
    }
    await _localStore.saveBudgets(budgets);
  }

  Budget createBudget({
    required String name,
    required double amount,
    required BudgetPeriod period,
  }) =>
      Budget(
        id: _uuid.v4(),
        name: name,
        amount: amount,
        spent: 0,
        period: period,
        createdAt: DateTime.now(),
      );

  Future<void> upsertGoal(SavingsGoal goal) async {
    final goals = getGoals();
    final index = goals.indexWhere((item) => item.id == goal.id);
    if (index == -1) {
      goals.add(goal);
    } else {
      goals[index] = goal;
    }
    await _localStore.saveGoals(goals);
  }

  SavingsGoal createGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) =>
      SavingsGoal(
        id: _uuid.v4(),
        name: name,
        targetAmount: targetAmount,
        savedAmount: 0,
        targetDate: targetDate,
      );

  Future<void> _syncTransaction(ExpenseTransaction transaction) async {
    final status = await _connectivity.checkConnectivity();
    if (status.contains(ConnectivityResult.none)) {
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toJson(), SetOptions(merge: true));
    } on Object {
      return;
    }
  }
}
