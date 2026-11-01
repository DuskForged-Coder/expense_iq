import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final currency =
        NumberFormat.simpleCurrency(name: ref.watch(appSettingsProvider).currencyCode);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Savings goals'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          for (final goal in finance.goals)
            GlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
                      ),
                      Icon(
                        goal.isComplete ? Icons.verified : Icons.flag,
                        color: goal.isComplete ? Colors.teal : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween<double>(begin: 0, end: goal.progress),
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${currency.format(goal.savedAmount)} saved of ${currency.format(goal.targetAmount)}',
                  ),
                  Text('Target: ${DateFormat.yMMMd().format(goal.targetDate)}'),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _addContribution(context, ref, goal.id),
                    icon: const Icon(Icons.add),
                    label: const Text('Add savings'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'goal-fab',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (context) => const _GoalEditor(),
        ),
        icon: const Icon(Icons.flag),
        label: const Text('Goal'),
      ),
    );
  }

  Future<void> _addContribution(
    BuildContext context,
    WidgetRef ref,
    String goalId,
  ) async {
    final amountController = TextEditingController();
    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add savings'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              double.tryParse(amountController.text),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    amountController.dispose();
    if (amount == null || amount <= 0) {
      return;
    }
    final goal = ref.read(financeProvider).goals.firstWhere((item) => item.id == goalId);
    await ref
        .read(financeProvider.notifier)
        .saveGoal(goal.copyWith(savedAmount: goal.savedAmount + amount));
  }
}

class _GoalEditor extends ConsumerStatefulWidget {
  const _GoalEditor();

  @override
  ConsumerState<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends ConsumerState<_GoalEditor> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _amount = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 180));

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
            Text('New savings goal', style: Theme.of(context).textTheme.headlineSmall),
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
              decoration: const InputDecoration(labelText: 'Target amount'),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                return parsed != null && parsed > 0 ? null : 'Enter a valid amount.';
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event),
              label: Text(DateFormat.yMMMd().format(_targetDate)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _targetDate,
    );
    if (date != null) {
      setState(() => _targetDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final goal = ref.read(financeProvider.notifier).newGoal(
          name: _name.text.trim(),
          targetAmount: double.parse(_amount.text),
          targetDate: _targetDate,
        );
    await ref.read(financeProvider.notifier).saveGoal(goal);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
