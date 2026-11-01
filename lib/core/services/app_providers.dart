import 'package:expense_iq/core/di/service_locator.dart';
import 'package:expense_iq/core/models/app_settings.dart';
import 'package:expense_iq/core/models/app_user.dart';
import 'package:expense_iq/core/models/budget.dart';
import 'package:expense_iq/core/models/savings_goal.dart';
import 'package:expense_iq/core/models/transaction.dart';
import 'package:expense_iq/core/services/auth_service.dart';
import 'package:expense_iq/core/services/finance_repository.dart';
import 'package:expense_iq/core/services/local_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsController, AppSettings>(
  (ref) => AppSettingsController(getIt<LocalStore>()),
);

final authProvider = StateNotifierProvider<AuthController, AsyncValue<AppUser?>>(
  (ref) => AuthController(getIt<AuthService>()),
);

final financeProvider =
    StateNotifierProvider<FinanceController, FinanceState>(
  (ref) => FinanceController(getIt<FinanceRepository>()),
);

class AppSettingsController extends StateNotifier<AppSettings> {
  AppSettingsController(this._store) : super(_store.readSettings());

  final LocalStore _store;

  Future<void> update(AppSettings settings) async {
    state = settings;
    await _store.saveSettings(settings);
  }

  void reload() {
    state = _store.readSettings();
  }
}

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController(this._service) : super(AsyncValue.data(_service.currentUser()));

  final AuthService _service;

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.signInWithEmail(email, password));
  }

  Future<void> signup(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.signUpWithEmail(email, password));
  }

  Future<void> googleLogin() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_service.signInWithGoogle);
  }

  Future<void> sendPasswordReset(String email) async {
    await _service.sendPasswordReset(email);
  }

  Future<void> logout() async {
    await _service.signOut();
    state = const AsyncValue.data(null);
  }
}

class FinanceState {
  const FinanceState({
    required this.transactions,
    required this.budgets,
    required this.goals,
  });

  final List<ExpenseTransaction> transactions;
  final List<Budget> budgets;
  final List<SavingsGoal> goals;

  double get income => transactions
      .where((item) => item.type == TransactionType.income)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get expense => transactions
      .where((item) => item.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get balance => income - expense;
}

class FinanceController extends StateNotifier<FinanceState> {
  FinanceController(this._repository) : super(_load(_repository));

  final FinanceRepository _repository;

  static FinanceState _load(FinanceRepository repository) {
    final transactions = repository.getTransactions();
    final budgets = repository.getBudgets().map((budget) {
      final spent = transactions
          .where(
            (transaction) =>
                transaction.type == TransactionType.expense &&
                _matchesBudget(budget.name, transaction.category),
          )
          .fold(0.0, (sum, transaction) => sum + transaction.amount);
      return budget.copyWith(spent: spent);
    }).toList();
    return FinanceState(
      transactions: transactions,
      budgets: budgets,
      goals: repository.getGoals(),
    );
  }

  static bool _matchesBudget(String budgetName, String category) {
    final normalizedBudget = budgetName.toLowerCase();
    final normalizedCategory = category.toLowerCase();
    return normalizedBudget.contains(normalizedCategory) ||
        normalizedCategory.contains(normalizedBudget.split(' ').first);
  }

  Future<void> saveTransaction(ExpenseTransaction transaction) async {
    await _repository.upsertTransaction(transaction);
    state = _load(_repository);
  }

  void refresh() {
    state = _load(_repository);
  }

  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    state = _load(_repository);
  }

  Future<void> saveBudget(Budget budget) async {
    await _repository.upsertBudget(budget);
    state = _load(_repository);
  }

  Future<void> saveGoal(SavingsGoal goal) async {
    await _repository.upsertGoal(goal);
    state = _load(_repository);
  }

  ExpenseTransaction newTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    required PaymentMethod paymentMethod,
    required String notes,
    String? receiptPath,
  }) =>
      _repository.createTransaction(
        title: title,
        amount: amount,
        type: type,
        category: category,
        date: date,
        paymentMethod: paymentMethod,
        notes: notes,
        receiptPath: receiptPath,
      );

  Budget newBudget({
    required String name,
    required double amount,
    required BudgetPeriod period,
  }) =>
      _repository.createBudget(name: name, amount: amount, period: period);

  SavingsGoal newGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
  }) =>
      _repository.createGoal(
        name: name,
        targetAmount: targetAmount,
        targetDate: targetDate,
      );
}
