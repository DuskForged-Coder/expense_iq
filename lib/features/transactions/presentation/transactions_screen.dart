import 'package:expense_iq/core/models/transaction.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _query = '';
  TransactionType? _type;
  String _sort = 'newest';

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final currency =
        NumberFormat.simpleCurrency(name: ref.watch(appSettingsProvider).currencyCode);
    final transactions = finance.transactions.where((item) {
      final query = _query.toLowerCase();
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.notes.toLowerCase().contains(query);
      final matchesType = _type == null || item.type == _type;
      return matchesQuery && matchesType;
    }).toList()
      ..sort((a, b) {
        return switch (_sort) {
          'amountHigh' => b.amount.compareTo(a.amount),
          'amountLow' => a.amount.compareTo(b.amount),
          _ => b.date.compareTo(a.date),
        };
      });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Transactions',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => _openEditor(context),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search transactions',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SegmentedButton<TransactionType?>(
                          segments: const <ButtonSegment<TransactionType?>>[
                            ButtonSegment<TransactionType?>(
                              value: null,
                              label: Text('All'),
                            ),
                            ButtonSegment<TransactionType?>(
                              value: TransactionType.income,
                              label: Text('Income'),
                            ),
                            ButtonSegment<TransactionType?>(
                              value: TransactionType.expense,
                              label: Text('Expense'),
                            ),
                          ],
                          selected: <TransactionType?>{_type},
                          onSelectionChanged: (value) =>
                              setState(() => _type = value.first),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        initialValue: _sort,
                        icon: const Icon(Icons.sort),
                        onSelected: (value) => setState(() => _sort = value),
                        itemBuilder: (context) => const <PopupMenuEntry<String>>[
                          PopupMenuItem(value: 'newest', child: Text('Newest')),
                          PopupMenuItem(value: 'amountHigh', child: Text('Highest amount')),
                          PopupMenuItem(value: 'amountLow', child: Text('Lowest amount')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    Future<void>.delayed(const Duration(milliseconds: 350)),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: GlassCard(
                        key: ValueKey<String>(item.id),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Icon(
                              item.type == TransactionType.income
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                            ),
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.category} - ${DateFormat.yMMMd().format(item.date)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                currency.format(item.amount),
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              Text(item.paymentMethod.name),
                            ],
                          ),
                          onTap: () => _openEditor(context, item),
                          onLongPress: () => _delete(item.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(String id) async {
    await ref.read(financeProvider.notifier).deleteTransaction(id);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Transaction deleted.')));
    }
  }

  Future<void> _openEditor(
    BuildContext context, [
    ExpenseTransaction? transaction,
  ]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _TransactionEditor(transaction: transaction),
    );
  }
}

class _TransactionEditor extends ConsumerStatefulWidget {
  const _TransactionEditor({this.transaction});

  final ExpenseTransaction? transaction;

  @override
  ConsumerState<_TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends ConsumerState<_TransactionEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _category;
  late final TextEditingController _notes;
  late TransactionType _type;
  late PaymentMethod _paymentMethod;

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;
    _title = TextEditingController(text: item?.title ?? '');
    _amount = TextEditingController(text: item?.amount.toStringAsFixed(2) ?? '');
    _category = TextEditingController(text: item?.category ?? 'General');
    _notes = TextEditingController(text: item?.notes ?? '');
    _type = item?.type ?? TransactionType.expense;
    _paymentMethod = item?.paymentMethod ?? PaymentMethod.card;
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _category.dispose();
    _notes.dispose();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.transaction == null ? 'Add transaction' : 'Edit transaction',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              SegmentedButton<TransactionType>(
                segments: const <ButtonSegment<TransactionType>>[
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: <TransactionType>{_type},
                onSelectionChanged: (value) => setState(() => _type = value.first),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required.'
                    : null,
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
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Category is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: PaymentMethod.values
                    .map(
                      (method) => DropdownMenuItem<PaymentMethod>(
                        value: method,
                        child: Text(method.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _paymentMethod = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Save transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final existing = widget.transaction;
    final item = existing == null
        ? ref.read(financeProvider.notifier).newTransaction(
              title: _title.text.trim(),
              amount: double.parse(_amount.text),
              type: _type,
              category: _category.text.trim(),
              date: DateTime.now(),
              paymentMethod: _paymentMethod,
              notes: _notes.text.trim(),
            )
        : existing.copyWith(
            title: _title.text.trim(),
            amount: double.parse(_amount.text),
            type: _type,
            category: _category.text.trim(),
            paymentMethod: _paymentMethod,
            notes: _notes.text.trim(),
          );
    await ref.read(financeProvider.notifier).saveTransaction(item);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
