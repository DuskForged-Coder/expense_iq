import 'package:expense_iq/core/models/budget.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final currency =
        NumberFormat.simpleCurrency(name: ref.watch(appSettingsProvider).currencyCode);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          for (final budget in finance.budgets)
            GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          budget.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Chip(label: Text(budget.period.name)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: budget.progress),
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${currency.format(budget.spent)} spent from ${currency.format(budget.amount)}',
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budget-fab',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => const _BudgetEditor(),
        ),
        icon: const Icon(Icons.savings),
        label: const Text('Budget'),
      ),
    );
  }
}

class _BudgetEditor extends ConsumerStatefulWidget {
  const _BudgetEditor();

  @override
  ConsumerState<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends ConsumerState<_BudgetEditor> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  BudgetPeriod _period = BudgetPeriod.monthly;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('New budget', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Name is required.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                return parsed != null && parsed > 0 ? null : 'Enter a valid amount.';
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<BudgetPeriod>(
              segments: const <ButtonSegment<BudgetPeriod>>[
                ButtonSegment(value: BudgetPeriod.weekly, label: Text('Weekly')),
                ButtonSegment(value: BudgetPeriod.monthly, label: Text('Monthly')),
              ],
              selected: <BudgetPeriod>{_period},
              onSelectionChanged: (value) => setState(() => _period = value.first),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save budget'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final budget = ref.read(financeProvider.notifier).newBudget(
          name: _name.text.trim(),
          amount: double.parse(_amount.text),
          period: _period,
        );
    await ref.read(financeProvider.notifier).saveBudget(budget);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
