import 'dart:convert';

import 'package:expense_iq/core/models/app_settings.dart';
import 'package:expense_iq/core/models/budget.dart';
import 'package:expense_iq/core/models/savings_goal.dart';
import 'package:expense_iq/core/models/transaction.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStore {
  LocalStore._(
    this._preferences,
    this._secureStorage,
    this._transactions,
    this._budgets,
    this._goals,
    this._settings,
  );

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;
  List<ExpenseTransaction> _transactions;
  List<Budget> _budgets;
  List<SavingsGoal> _goals;
  AppSettings _settings;

  static const String _transactionsKey = 'transactions';
  static const String _budgetsKey = 'budgets';
  static const String _goalsKey = 'savings_goals';
  static const String _settingsKey = 'settings';

  static Future<LocalStore> create(
    SharedPreferences preferences,
    FlutterSecureStorage secureStorage,
  ) async {
    final store = LocalStore._(
      preferences,
      secureStorage,
      <ExpenseTransaction>[],
      <Budget>[],
      <SavingsGoal>[],
      AppSettings.defaults,
    );
    store._transactions =
        store._decodeTransactions(await secureStorage.read(key: _transactionsKey)) ??
            store._decodeTransactions(preferences.getString(_transactionsKey)) ??
            store._seedTransactions();
    store._budgets = store._decodeBudgets(await secureStorage.read(key: _budgetsKey)) ??
        store._decodeBudgets(preferences.getString(_budgetsKey)) ??
        store._seedBudgets();
    store._goals = store._decodeGoals(await secureStorage.read(key: _goalsKey)) ??
        store._decodeGoals(preferences.getString(_goalsKey)) ??
        store._seedGoals();
    store._settings = store._decodeSettings(preferences.getString(_settingsKey)) ??
        AppSettings.defaults;
    await store.saveTransactions(store._transactions);
    await store.saveBudgets(store._budgets);
    await store.saveGoals(store._goals);
    return store;
  }

  List<ExpenseTransaction> readTransactions() => List.unmodifiable(_transactions);

  Future<void> saveTransactions(List<ExpenseTransaction> transactions) async {
    _transactions = List<ExpenseTransaction>.from(transactions);
    await _secureStorage.write(
      key: _transactionsKey,
      value: jsonEncode(transactions.map((item) => item.toJson()).toList()),
    );
    await _preferences.remove(_transactionsKey);
  }

  List<Budget> readBudgets() => List.unmodifiable(_budgets);

  Future<void> saveBudgets(List<Budget> budgets) async {
    _budgets = List<Budget>.from(budgets);
    await _secureStorage.write(
      key: _budgetsKey,
      value: jsonEncode(budgets.map((item) => item.toJson()).toList()),
    );
    await _preferences.remove(_budgetsKey);
  }

  List<SavingsGoal> readGoals() => List.unmodifiable(_goals);

  Future<void> saveGoals(List<SavingsGoal> goals) async {
    _goals = List<SavingsGoal>.from(goals);
    await _secureStorage.write(
      key: _goalsKey,
      value: jsonEncode(goals.map((item) => item.toJson()).toList()),
    );
    await _preferences.remove(_goalsKey);
  }

  AppSettings readSettings() => _settings;

  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    await _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<String> exportBackup() async {
    final payload = <String, Object?>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': readTransactions().map((item) => item.toJson()).toList(),
      'budgets': readBudgets().map((item) => item.toJson()).toList(),
      'goals': readGoals().map((item) => item.toJson()).toList(),
      'settings': readSettings().toJson(),
    };
    return jsonEncode(payload);
  }

  Future<void> restoreBackup(String rawJson) async {
    final payload = jsonDecode(rawJson) as Map<String, Object?>;
    final transactions = (payload['transactions'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(ExpenseTransaction.fromJson)
        .toList();
    final budgets = (payload['budgets'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(Budget.fromJson)
        .toList();
    final goals = (payload['goals'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(SavingsGoal.fromJson)
        .toList();
    final settings =
        AppSettings.fromJson(payload['settings'] as Map<String, Object?>);
    await saveTransactions(transactions);
    await saveBudgets(budgets);
    await saveGoals(goals);
    await saveSettings(settings);
  }

  List<ExpenseTransaction>? _decodeTransactions(String? raw) {
    if (raw == null) {
      return null;
    }
    final items = jsonDecode(raw) as List<Object?>;
    return items
        .cast<Map<String, Object?>>()
        .map(ExpenseTransaction.fromJson)
        .toList();
  }

  List<Budget>? _decodeBudgets(String? raw) {
    if (raw == null) {
      return null;
    }
    final items = jsonDecode(raw) as List<Object?>;
    return items.cast<Map<String, Object?>>().map(Budget.fromJson).toList();
  }

  List<SavingsGoal>? _decodeGoals(String? raw) {
    if (raw == null) {
      return null;
    }
    final items = jsonDecode(raw) as List<Object?>;
    return items
        .cast<Map<String, Object?>>()
        .map(SavingsGoal.fromJson)
        .toList();
  }

  AppSettings? _decodeSettings(String? raw) {
    if (raw == null) {
      return null;
    }
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  List<ExpenseTransaction> _seedTransactions() => <ExpenseTransaction>[
        ExpenseTransaction(
          id: 'seed-income',
          title: 'Salary',
          amount: 5200,
          type: TransactionType.income,
          category: 'Income',
          date: DateTime.now().subtract(const Duration(days: 2)),
          paymentMethod: PaymentMethod.bankTransfer,
          notes: 'Monthly payroll',
          synced: false,
        ),
        ExpenseTransaction(
          id: 'seed-rent',
          title: 'Apartment rent',
          amount: 1650,
          type: TransactionType.expense,
          category: 'Housing',
          date: DateTime.now().subtract(const Duration(days: 1)),
          paymentMethod: PaymentMethod.bankTransfer,
          notes: 'July rent',
          synced: false,
        ),
        ExpenseTransaction(
          id: 'seed-grocery',
          title: 'Whole Market',
          amount: 146.82,
          type: TransactionType.expense,
          category: 'Groceries',
          date: DateTime.now(),
          paymentMethod: PaymentMethod.card,
          notes: 'Weekly groceries',
          synced: false,
        ),
      ];

  List<Budget> _seedBudgets() => <Budget>[
        Budget(
          id: 'budget-food',
          name: 'Food and groceries',
          amount: 700,
          spent: 312,
          period: BudgetPeriod.monthly,
          createdAt: DateTime.now(),
        ),
        Budget(
          id: 'budget-weekly',
          name: 'Weekly flexible',
          amount: 250,
          spent: 96,
          period: BudgetPeriod.weekly,
          createdAt: DateTime.now(),
        ),
      ];

  List<SavingsGoal> _seedGoals() => <SavingsGoal>[
        SavingsGoal(
          id: 'goal-emergency',
          name: 'Emergency fund',
          targetAmount: 12000,
          savedAmount: 4400,
          targetDate: DateTime.now().add(const Duration(days: 240)),
        ),
      ];
}
