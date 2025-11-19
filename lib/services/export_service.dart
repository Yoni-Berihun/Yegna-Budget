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

      // Precompute category totals
      final Map<String, double> categoryTotals = {};
      for (final e in budget.expenses) {
        categoryTotals.update(
          e.category,
          (v) => v + e.amount,
          ifAbsent: () => e.amount,
        );
      }

      // Sort expenses by date (newest first)
      final expenses = [...budget.expenses]
        ..sort((a, b) => b.date.compareTo(a.date));

      pdf.addPage(
        pw.MultiPage(
          pageTheme: _pageTheme(),
          header: (context) => _header(context, now),
          footer: (context) => _footer(context),
          build: (context) => [
            _summarySection(budget),
            pw.SizedBox(height: 20),
            if (categoryTotals.isNotEmpty) _categoryBreakdown(categoryTotals),
            pw.SizedBox(height: 20),
            _expensesTable(expenses, dateFormat),
            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated on: ${dateFormat.format(now)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
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

  // Export to CSV (unchanged)
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

  // ---------- Helpers for PDF ----------

  static pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.fromLTRB(32, 72, 32, 60),
      theme: pw.ThemeData.withFont(
        // Use built-in Helvetica without wrapping in Font.ttf (expects ByteData).
        base: pw.Font.helvetica(),
      ),
    );
  }

  static pw.Widget _header(pw.Context context, DateTime now) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 34,
            height: 34,
            decoration: pw.BoxDecoration(
              color: PdfColors.orange400,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                'YB',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'YegnaBudget Expense Report',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                DateFormat('EEE, MMM d, yyyy • HH:mm').format(now),
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(4),
              border: pw.Border.all(color: PdfColors.green300, width: 0.5),
            ),
            child: pw.Text(
              'ETB',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.green800,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
      ),
    );
  }

  static pw.Widget _summarySection(BudgetState budget) {
    pw.Widget _summaryCard({
      required String title,
      required String value,
      required PdfColor color,
      PdfColor? bg,
    }) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: bg ?? PdfColors.white,
          borderRadius: pw.BorderRadius.circular(8),
          // PdfColor has no withOpacity; use the original color directly or replace with a lighter fixed shade.
          border: pw.Border.all(color: color, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Budget Summary',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              child: _summaryCard(
                title: 'Total Budget',
                value: '${budget.totalBudget.toStringAsFixed(2)} ETB',
                color: PdfColors.blue800,
                bg: PdfColors.blue50,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _summaryCard(
                title: 'Spent',
                value: '${budget.spentAmount.toStringAsFixed(2)} ETB',
                color: PdfColors.red800,
                bg: PdfColors.red50,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _summaryCard(
                title: 'Remaining',
                value: '${budget.remaining.toStringAsFixed(2)} ETB',
                color: PdfColors.green800,
                bg: PdfColors.green50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _categoryBreakdown(Map<String, double> totals) {
    final items = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalAll = items.fold<double>(0, (s, e) => s + e.value);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'By Category',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
            bottom: const pw.BorderSide(color: PdfColors.grey400, width: 0.8),
            top: const pw.BorderSide(color: PdfColors.grey400, width: 0.8),
            left: pw.BorderSide.none,
            right: pw.BorderSide.none,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _cell('Category', bold: true, pad: 8),
                _cell('Amount (ETB)', bold: true, pad: 8, align: pw.TextAlign.right),
                _cell('Share', bold: true, pad: 8, align: pw.TextAlign.right),
              ],
            ),
            ...List.generate(items.length, (i) {
              final e = items[i];
              final share = totalAll == 0 ? 0 : (e.value / totalAll) * 100;
              final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: bg),
                children: [
                  _cell(e.key, pad: 8),
                  _cell(e.value.toStringAsFixed(2), pad: 8, align: pw.TextAlign.right),
                  _cell('${share.toStringAsFixed(1)}%', pad: 8, align: pw.TextAlign.right),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _expensesTable(List expenses, DateFormat dateFormat) {
    // Header
    final headers = [
      'Date',
      'Category',
      'Amount (ETB)',
      'Reason Type',
      'Reason',
      'Description',
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Expenses (${expenses.length})',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.6),
            bottom: const pw.BorderSide(color: PdfColors.grey400, width: 0.8),
            top: const pw.BorderSide(color: PdfColors.grey400, width: 0.8),
            left: pw.BorderSide.none,
            right: pw.BorderSide.none,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),   // Date
            1: const pw.FlexColumnWidth(2),   // Category
            2: const pw.FlexColumnWidth(1.8), // Amount
            3: const pw.FlexColumnWidth(2),   // Reason Type
            4: const pw.FlexColumnWidth(3),   // Reason
            5: const pw.FlexColumnWidth(4),   // Description
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: headers
                  .map((h) => _cell(h, bold: true, pad: 8))
                  .toList(),
            ),
            ...List.generate(expenses.length, (i) {
              final e = expenses[i];
              final bg = i.isEven ? PdfColors.white : PdfColors.grey50;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: bg),
                children: [
                  _cell(dateFormat.format(e.date), pad: 8),
                  _cell(e.category, pad: 8),
                  _cell(e.amount.toStringAsFixed(2), pad: 8, align: pw.TextAlign.right),
                  _cell(e.reasonType, pad: 8),
                  _cell(e.reason, pad: 8),
                  _cell((e.description?.isNotEmpty ?? false) ? e.description! : '-', pad: 8),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    bool bold = false,
    double pad = 6,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(pad),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.grey800,
        ),
      ),
    );
  }
}