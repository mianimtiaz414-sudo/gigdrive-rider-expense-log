import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rider_expense_tracker/data/models/expense_model.dart';




class PdfReportService {
  PdfReportService._();

  static final PdfColor _accent = PdfColor.fromHex('#00A152');
  static final PdfColor _loss = PdfColor.fromHex('#D32F2F');
  static final PdfColor _earn = PdfColor.fromHex('#0277BD');

  static Future<Uint8List> buildLedgerReport({
    required List<ExpenseModel> logs,
    required String currencyCode,
    required String appName,
    required DateTime generatedAt,
  }) async {
    final NumberFormat number = NumberFormat('#,##0.00', 'en_US');
    final NumberFormat distance = NumberFormat('#,##0.##', 'en_US');
    final DateFormat dayFmt = DateFormat('dd MMM yyyy', 'en');
    final DateFormat monthFmt = DateFormat('MMMM yyyy', 'en');
    final DateFormat stampFmt = DateFormat('dd MMM yyyy, HH:mm', 'en');

    String money(double v) {
      final String sign = v < 0 ? '-' : '';
      return '$sign$currencyCode ${number.format(v.abs())}';
    }

    
    final List<ExpenseModel> sorted = List<ExpenseModel>.of(logs)
      ..sort((ExpenseModel a, ExpenseModel b) => b.date.compareTo(a.date));
    final Map<String, List<ExpenseModel>> byMonth =
        <String, List<ExpenseModel>>{};
    for (final ExpenseModel l in sorted) {
      final String key =
          '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}';
      byMonth.putIfAbsent(key, () => <ExpenseModel>[]).add(l);
    }

    double totalEarned = 0;
    double totalSpent = 0;
    double totalFuel = 0;
    double totalRepairs = 0;
    for (final ExpenseModel l in sorted) {
      totalEarned += l.earnings;
      totalFuel += l.fuel;
      totalRepairs += l.otherRepairs;
      totalSpent += l.totalExpenses;
    }
    final double totalNet = totalEarned - totalSpent;

    pw.Widget statBox(String label, String value, PdfColor color) {
      return pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                label,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pw.Document doc = pw.Document(
      title: '$appName ledger report',
      author: appName,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
        header: (pw.Context context) {
          if (context.pageNumber == 1) {
            return pw.SizedBox();
          }
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text(
              '$appName - Ledger report',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          );
        },
        build: (pw.Context context) {
          final List<pw.Widget> content = <pw.Widget>[
            pw.Text(
              appName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: _accent,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Ledger report',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated ${stampFmt.format(generatedAt)}  |  '
              '${sorted.length} entries  |  Currency: $currencyCode',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              children: <pw.Widget>[
                statBox('Total Earnings', money(totalEarned), _earn),
                pw.SizedBox(width: 8),
                statBox('Total Expenses', money(totalSpent), _loss),
                pw.SizedBox(width: 8),
                statBox(
                  'Net Profit',
                  money(totalNet),
                  totalNet >= 0 ? _accent : _loss,
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Fuel ${money(totalFuel)}   |   Other repairs ${money(totalRepairs)}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 18),
          ];

          byMonth.forEach((String key, List<ExpenseModel> items) {
            double earned = 0;
            double spent = 0;
            for (final ExpenseModel l in items) {
              earned += l.earnings;
              spent += l.totalExpenses;
            }
            final double net = earned - spent;

            content.add(
              pw.Text(
                monthFmt.format(items.first.date),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            );
            content.add(pw.SizedBox(height: 6));

            final List<List<String>> rows = items
                .map((ExpenseModel l) => <String>[
                      dayFmt.format(l.date),
                      number.format(l.earnings),
                      number.format(l.fuel),
                      number.format(l.otherRepairs),
                      number.format(l.totalExpenses),
                      '${l.netProfit < 0 ? '-' : ''}${number.format(l.netProfit.abs())}',
                      distance.format(l.mileage),
                    ])
                .toList();

            content.add(
              pw.TableHelper.fromTextArray(
                context: context,
                headers: <String>[
                  'Date',
                  'Earnings',
                  'Fuel',
                  'Repairs',
                  'Expenses',
                  'Net',
                  'Odometer km',
                ],
                data: rows,
                border:
                    pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(color: _accent),
                cellStyle: const pw.TextStyle(fontSize: 8.5),
                cellPadding:
                    const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                cellAlignment: pw.Alignment.centerRight,
                cellAlignments: <int, pw.Alignment>{
                  0: pw.Alignment.centerLeft,
                },
                headerAlignments: <int, pw.Alignment>{
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                },
                oddRowDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey100),
              ),
            );

            content.add(pw.SizedBox(height: 5));
            content.add(
              pw.Text(
                'Month total: earnings ${money(earned)}  |  '
                'expenses ${money(spent)}  |  net ${money(net)}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: net >= 0 ? _accent : _loss,
                ),
              ),
            );
            content.add(pw.SizedBox(height: 18));
          });

          return content;
        },
      ),
    );

    return doc.save();
  }
}
