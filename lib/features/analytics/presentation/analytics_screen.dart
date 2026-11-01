import 'package:expense_iq/core/models/transaction.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _range = 'monthly';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(financeProvider).transactions;
    final expenses =
        transactions.where((item) => item.type == TransactionType.expense).toList();
    final grouped = <String, double>{};
    for (final item in expenses) {
      grouped[item.category] = (grouped[item.category] ?? 0) + item.amount;
    }
    final currency =
        NumberFormat.simpleCurrency(name: ref.watch(appSettingsProvider).currencyCode);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: <Widget>[
            Text(
              'Statistics',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const <ButtonSegment<String>>[
                ButtonSegment(value: 'weekly', label: Text('Week')),
                ButtonSegment(value: 'monthly', label: Text('Month')),
                ButtonSegment(value: 'yearly', label: Text('Year')),
              ],
              selected: <String>{_range},
              onSelectionChanged: (value) => setState(() => _range = value.first),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Category split', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 46,
                        sections: grouped.entries.map((entry) {
                          final index = grouped.keys.toList().indexOf(entry.key);
                          return PieChartSectionData(
                            value: entry.value,
                            title: entry.key,
                            radius: 72,
                            color: Colors.primaries[index % Colors.primaries.length],
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Cash flow', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                          topTitles: AxisTitles(),
                        ),
                        barGroups: _barGroups(transactions),
                      ),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Trend', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(),
                          rightTitles: AxisTitles(),
                          topTitles: AxisTitles(),
                        ),
                        lineBarsData: <LineChartBarData>[
                          LineChartBarData(
                            spots: _lineSpots(expenses),
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 4,
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Total expenses: ${currency.format(expenses.fold(0.0, (sum, item) => sum + item.amount))}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _barGroups(List<ExpenseTransaction> transactions) {
    final income = transactions
        .where((item) => item.type == TransactionType.income)
        .fold(0.0, (sum, item) => sum + item.amount);
    final expense = transactions
        .where((item) => item.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    return <BarChartGroupData>[
      BarChartGroupData(x: 0, barRods: <BarChartRodData>[
        BarChartRodData(toY: income, color: Colors.teal, width: 32),
      ]),
      BarChartGroupData(x: 1, barRods: <BarChartRodData>[
        BarChartRodData(toY: expense, color: Colors.deepOrange, width: 32),
      ]),
    ];
  }

  List<FlSpot> _lineSpots(List<ExpenseTransaction> expenses) {
    if (expenses.isEmpty) {
      return const <FlSpot>[FlSpot(0, 0)];
    }
    final sorted = expenses.toList()..sort((a, b) => a.date.compareTo(b.date));
    return List<FlSpot>.generate(
      sorted.length,
      (index) => FlSpot(index.toDouble(), sorted[index].amount),
    );
  }
}
