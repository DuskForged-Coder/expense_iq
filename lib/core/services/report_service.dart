import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:expense_iq/core/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportService {
  final DateFormat _dateFormat = DateFormat.yMMMd();

  Future<File> exportCsv(List<ExpenseTransaction> transactions) async {
    final buffer = StringBuffer('Date,Title,Type,Category,Method,Amount,Notes\n');
    for (final item in transactions) {
      buffer.writeln(
        [
          _dateFormat.format(item.date),
          item.title,
          item.type.name,
          item.category,
          item.paymentMethod.name,
          item.amount.toStringAsFixed(2),
          item.notes,
        ].map(_csvCell).join(','),
      );
    }
    return _writeFile('expenseiq-report.csv', utf8.encode(buffer.toString()));
  }

  Future<File> exportExcel(List<ExpenseTransaction> transactions) async {
    final excel = Excel.createExcel();
    final sheet = excel['Transactions'];
    sheet.appendRow(<CellValue>[
      TextCellValue('Date'),
      TextCellValue('Title'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Method'),
      TextCellValue('Amount'),
      TextCellValue('Notes'),
    ]);
    for (final item in transactions) {
      sheet.appendRow(<CellValue>[
        TextCellValue(_dateFormat.format(item.date)),
        TextCellValue(item.title),
        TextCellValue(item.type.name),
        TextCellValue(item.category),
        TextCellValue(item.paymentMethod.name),
        DoubleCellValue(item.amount),
        TextCellValue(item.notes),
      ]);
    }
    return _writeFile('expenseiq-report.xlsx', excel.encode()!);
  }

  Future<File> exportPdf(List<ExpenseTransaction> transactions) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        build: (context) => <pw.Widget>[
          pw.Text('ExpenseIQ Report', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: <String>['Date', 'Title', 'Type', 'Category', 'Amount'],
            data: transactions
                .map(
                  (item) => <String>[
                    _dateFormat.format(item.date),
                    item.title,
                    item.type.name,
                    item.category,
                    item.amount.toStringAsFixed(2),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return _writeFile('expenseiq-report.pdf', await document.save());
  }

  String _csvCell(String value) => '"${value.replaceAll('"', '""')}"';

  Future<File> _writeFile(String name, List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name');
    return file.writeAsBytes(bytes, flush: true);
  }
}
