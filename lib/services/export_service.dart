import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../logic/providers/budget_provider.dart';

class ExportService {
  // Export to PDF
  static Future<void> exportToPDF(BudgetState budget) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      final now = DateTime.now();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'YegnaBudget Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Text(
              'Budget Summary',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Budget'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${budget.totalBudget.toStringAsFixed(2)} ETB',
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Spent'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${budget.spentAmount.toStringAsFixed(2)} ETB',
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Remaining'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        '${budget.remaining.toStringAsFixed(2)} ETB',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Expenses
            pw.Text(
              'Expenses (${budget.expenses.length})',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            ...budget.expenses.map((expense) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          expense.category,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${expense.amount.toStringAsFixed(2)} ETB',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Reason: ${expense.reason}'),
                    pw.Text('Type: ${expense.reasonType}'),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      pw.Text('Description: ${expense.description!}'),
                    pw.Text('Date: ${dateFormat.format(expense.date)}'),
                  ],
                ),
              );
            }).toList(),

            pw.SizedBox(height: 20),
            pw.Text(
              'Generated on: ${dateFormat.format(now)}',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ),
      );

      // Save PDF
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/yegna_budget_report_${now.millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      // Share PDF
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'YegnaBudget Expense Report');
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  // Export to CSV
  static Future<void> exportToCSV(BudgetState budget) async {
    try {
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
      final now = DateTime.now();

      final buffer = StringBuffer();

      // Header
      buffer.writeln('YegnaBudget Expense Report');
      buffer.writeln('Generated on: ${dateFormat.format(now)}');
      buffer.writeln('');
      buffer.writeln('Summary');
      buffer.writeln('Total Budget,${budget.totalBudget.toStringAsFixed(2)}');
      buffer.writeln('Spent,${budget.spentAmount.toStringAsFixed(2)}');
      buffer.writeln('Remaining,${budget.remaining.toStringAsFixed(2)}');
      buffer.writeln('');

      // Expenses header
      buffer.writeln('Expenses');
      buffer.writeln('Date,Category,Amount,Reason Type,Reason,Description');

      // Expenses data
      for (var expense in budget.expenses) {
        buffer.writeln(
          '${dateFormat.format(expense.date)},'
          '${expense.category},'
          '${expense.amount.toStringAsFixed(2)},'
          '${expense.reasonType},'
          '"${expense.reason.replaceAll('"', '""')}",'
          '"${(expense.description?.replaceAll('"', '""') ?? "")}"',
        );
      }

      // Save CSV
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/yegna_budget_report_${now.millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(buffer.toString());

      // Share CSV
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'YegnaBudget Expense Report');
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}
