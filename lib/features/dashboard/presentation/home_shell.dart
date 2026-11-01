import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientShell(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.space_dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'primary-fab',
        onPressed: () => context.go('/transactions'),
        icon: const Icon(Icons.add_card),
        label: const Text('Add'),
      ),
    );
  }
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final currency = NumberFormat.simpleCurrency(
      name: ref.watch(appSettingsProvider).currencyCode,
    );
    return RefreshIndicator(
      onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 350)),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            title: Hero(
              tag: 'brand',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'ExpenseIQ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList.list(
              children: <Widget>[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Total balance', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      Text(
                        currency.format(finance.balance),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: finance.income == 0 ? 0 : finance.expense / finance.income,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MetricTile(
                        label: 'Income',
                        value: currency.format(finance.income),
                        icon: Icons.trending_up,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MetricTile(
                        label: 'Expense',
                        value: currency.format(finance.expense),
                        icon: Icons.trending_down,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Budget overview',
                  action: () => context.go('/settings/budgets'),
                ),
                ...finance.budgets.map(
                  (budget) => GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(budget.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: budget.progress,
                          minHeight: 9,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currency.format(budget.spent)} of ${currency.format(budget.amount)}',
                        ),
                      ],
                    ),
                  ),
                ),
                _SectionHeader(
                  title: 'Savings overview',
                  action: () => context.go('/settings/savings'),
                ),
                ...finance.goals.map(
                  (goal) => GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircularProgressIndicator(value: goal.progress),
                      title: Text(goal.name),
                      subtitle: Text('${(goal.progress * 100).round()}% complete'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
                _SectionHeader(
                  title: 'Recent transactions',
                  action: () => context.go('/transactions'),
                ),
                ...finance.transactions.take(5).map(
                  (item) => GlassCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Icon(_iconFor(item.category))),
                      title: Text(item.title),
                      subtitle: Text(DateFormat.yMMMd().format(item.date)),
                      trailing: Text(
                        currency.format(item.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: item.type.name == 'income'
                              ? Colors.teal
                              : Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String category) {
    return switch (category.toLowerCase()) {
      'income' => Icons.payments,
      'housing' => Icons.home,
      'groceries' => Icons.shopping_basket,
      _ => Icons.category,
    };
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final VoidCallback action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(onPressed: action, icon: const Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}
