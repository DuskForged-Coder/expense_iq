import 'package:expense_iq/core/di/service_locator.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/core/services/report_service.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Export reports', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _loading ? null : () => _export('pdf'),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _loading ? null : () => _export('excel'),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Export Excel'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _loading ? null : () => _export('csv'),
                  icon: const Icon(Icons.description),
                  label: const Text('Export CSV'),
                ),
                if (_loading) ...const <Widget>[
                  SizedBox(height: 16),
                  LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(String type) async {
    setState(() => _loading = true);
    try {
      final transactions = ref.read(financeProvider).transactions;
      final service = getIt<ReportService>();
      final file = switch (type) {
        'pdf' => await service.exportPdf(transactions),
        'excel' => await service.exportExcel(transactions),
        _ => await service.exportCsv(transactions),
      };
      await Share.shareXFiles(<XFile>[XFile(file.path)], text: 'ExpenseIQ report');
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
