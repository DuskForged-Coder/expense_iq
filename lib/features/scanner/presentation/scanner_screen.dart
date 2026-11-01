import 'package:expense_iq/core/di/service_locator.dart';
import 'package:expense_iq/core/models/transaction.dart';
import 'package:expense_iq/core/services/app_providers.dart';
import 'package:expense_iq/core/services/receipt_scanner_service.dart';
import 'package:expense_iq/shared/widgets/glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  ReceiptScanResult? _result;
  bool _loading = false;
  String? _imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Receipt scanner'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.document_scanner,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : () => _scan(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan with camera'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _loading ? null : () => _scan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Import from gallery'),
                ),
                if (_loading) ...const <Widget>[
                  SizedBox(height: 16),
                  LinearProgressIndicator(),
                ],
              ],
            ),
          ),
          if (_result != null) ...<Widget>[
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Detected details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _Detail(label: 'Merchant', value: _result!.merchant ?? 'Unknown'),
                  _Detail(
                    label: 'Amount',
                    value: _result!.amount?.toStringAsFixed(2) ?? 'Not detected',
                  ),
                  _Detail(
                    label: 'Date',
                    value: _result!.date?.toIso8601String().split('T').first ??
                        'Today',
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _result!.amount == null ? null : _createTransaction,
                    icon: const Icon(Icons.add_card),
                    label: const Text('Create transaction'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _result!.rawText,
                    maxLines: 8,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _scan(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 92);
    if (image == null) {
      return;
    }
    setState(() {
      _loading = true;
      _imagePath = image.path;
    });
    try {
      final result = await getIt<ReceiptScannerService>().scanImage(image.path);
      setState(() => _result = result);
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

  Future<void> _createTransaction() async {
    final result = _result;
    if (result == null || result.amount == null) {
      return;
    }
    final transaction = ref.read(financeProvider.notifier).newTransaction(
          title: result.merchant ?? 'Receipt transaction',
          amount: result.amount!,
          type: TransactionType.expense,
          category: 'Receipts',
          date: result.date ?? DateTime.now(),
          paymentMethod: PaymentMethod.card,
          notes: 'Created from receipt OCR.',
          receiptPath: _imagePath,
        );
    await ref.read(financeProvider.notifier).saveTransaction(transaction);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction created from receipt.')),
      );
    }
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(width: 96, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
