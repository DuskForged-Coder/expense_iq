import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

class ReceiptScanResult {
  const ReceiptScanResult({
    required this.rawText,
    required this.amount,
    required this.merchant,
    required this.date,
  });

  final String rawText;
  final double? amount;
  final String? merchant;
  final DateTime? date;
}

class ReceiptScannerService {
  Future<ReceiptScanResult> scanImage(String imagePath) async {
    final recognizer = TextRecognizer();
    final inputImage = InputImage.fromFilePath(imagePath);
    final text = await recognizer.processImage(inputImage);
    await recognizer.close();
    final raw = text.text;
    return ReceiptScanResult(
      rawText: raw,
      amount: _detectAmount(raw),
      merchant: _detectMerchant(raw),
      date: _detectDate(raw),
    );
  }

  double? _detectAmount(String raw) {
    final amountPattern = RegExp(r'(?:(?:total|amount|paid)\D{0,12})?(\d+[\.,]\d{2})',
        caseSensitive: false);
    final matches = amountPattern.allMatches(raw).toList();
    if (matches.isEmpty) {
      return null;
    }
    final values = matches
        .map((match) => double.tryParse(match.group(1)!.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
    values.sort();
    return values.isEmpty ? null : values.last;
  }

  String? _detectMerchant(String raw) {
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.length >= 3)
        .toList();
    return lines.isEmpty ? null : lines.first;
  }

  DateTime? _detectDate(String raw) {
    final patterns = <DateFormat>[
      DateFormat('MM/dd/yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];
    final dateMatch =
        RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|\d{4}-\d{2}-\d{2})')
            .firstMatch(raw);
    if (dateMatch == null) {
      return null;
    }
    final value = dateMatch.group(1)!;
    for (final pattern in patterns) {
      try {
        return pattern.parseStrict(value);
      } on FormatException {
        continue;
      }
    }
    return null;
  }
}
