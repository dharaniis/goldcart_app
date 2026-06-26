import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldbill_calc/models/billmodels.dart';
import 'package:goldbill_calc/pages/Result/pdf_view.dart';
import 'package:goldbill_calc/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class GenerateEstimatePdf extends ConsumerWidget {
  const GenerateEstimatePdf({super.key});

  Future<pw.Document> buildEstimatePdf(
    List<JewelleryItem> items,
    List<String> rateList,
  ) async {
    final pdf = pw.Document(title: 'gold_bill_estimate');

    final amountFormat = NumberFormat('#,##,##0', 'en_IN');
    final weightFormat = NumberFormat('0.000');
    final dateFormat = DateFormat('dd-MM-yyyy');
    final generatedDate = dateFormat.format(DateTime.now());

    String amount(num value) => amountFormat.format(value.round());
    String weight(num value) => weightFormat.format(value);

    final purityIndex = {'18K': 0, '22K': 1, '24K': 2};

    final summaryBorderColor = PdfColor.fromHex('#9F9F9F');
    final summaryDividerColor = PdfColor.fromHex('#E5E5E5');

    double totalGrossWeight = 0;
    double totalStoneCost = 0;
    double totalWastage = 0;
    double totalMaking = 0;
    double totalGst = 0;
    double grandTotal = 0;

    final tableRows = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      final selectedIndex = purityIndex[item.purity] ?? 1;
      final goldRate = double.parse(rateList[selectedIndex]);

      final itemGoldValue = item.calculateGoldValue(goldRate);
      final itemStoneCost = item.calculateStoneCost();
      final itemWastage = item.calculateWastageAmount(goldRate);
      final itemMaking = item.calculateMakingCharges(goldRate);
      final itemGst = item.calculateGstAmount(goldRate);
      final itemTotal = item.calculateFinalAmount(goldRate);

      totalGrossWeight += item.grossWeight * item.quantity;
      totalStoneCost += itemStoneCost;
      totalWastage += itemWastage;
      totalMaking += itemMaking;
      totalGst += itemGst;
      grandTotal += itemTotal;

      return {
        'slNo': index + 1,
        'type': item.type,
        'purity': item.purity,
        'qty': item.quantity,
        'goldRate': goldRate,
        'grossWeight': item.grossWeight * item.quantity,
        'netWeight': item.netWeight * item.quantity,
        'stoneWeight': item.stoneWeight * item.quantity,
        'goldValue': itemGoldValue,
        'stoneCost':
            '${amount(itemStoneCost)}${item.stoneWeight > 0 ? '\n(@ ${item.stoneRate}/g)' : ''}',
        'wastage':
            '${amount(itemWastage)}\n${item.isWastageInGrams ? '(${item.wastageCharge}g)' : '(@ ${item.wastageCharge}%)'}',
        'making':
            '${amount(itemMaking)}\n${item.isMakingFixed ? '(fixed)' : '(@ ${item.makingCharge}%)'}',
        'gst': itemGst,
        'total': itemTotal,
        'gstLabel': item.enableGst ? amount(itemGst) : 'Off',
      };
    }).toList();

    final subtotalIncludingGst = grandTotal;
    final balanceGrandTotal = subtotalIncludingGst;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(18, 18, 18, 28),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 10),
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'This estimate is for reference only. Final billing may vary based on live gold rate, store policy, GST, wastage, making charges, stone valuation and rounding.',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'Page ${context.pageNumber} / ${context.pagesCount}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'GOLD BILL ESTIMATE',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Date: $generatedDate',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey800,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: {
              0: const pw.FixedColumnWidth(26),
              1: const pw.FlexColumnWidth(1.35),
              2: const pw.FixedColumnWidth(34),
              3: const pw.FixedColumnWidth(40),
              4: const pw.FixedColumnWidth(54),
              5: const pw.FixedColumnWidth(50),
              6: const pw.FixedColumnWidth(50),
              7: const pw.FixedColumnWidth(64),
              8: const pw.FixedColumnWidth(64),
              9: const pw.FixedColumnWidth(64),
              10: const pw.FixedColumnWidth(48),
              11: const pw.FixedColumnWidth(74),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _headerCell('S.No'),
                  _headerCell('Item\nName'),
                  _headerCell('Purity'),
                  _headerCell('Qty'),
                  _headerCell('Gold\nRate/Gm'),
                  _headerCell('Gold Wt\n(gm)'),
                  _headerCell('Total Wt\n(gm)'),
                  _headerCell('Making'),
                  _headerCell('Wastage\nCost'),
                  _headerCell('Stone\nCost'),
                  _headerCell('GST @ 3%'),
                  _headerCell('Total Price'),
                ],
              ),
              ...tableRows.map((row) {
                return pw.TableRow(
                  children: [
                    _bodyCell(row['slNo'].toString()),
                    _bodyCell(row['type'].toString()),
                    _bodyCell(row['purity'].toString()),
                    _bodyCell(row['qty'].toString()),
                    _bodyCell(amount(row['goldRate'] as double)),
                    _bodyCell(weight(row['netWeight'] as double)),
                    _bodyCell(weight(row['grossWeight'] as double)),
                    _bodyCell(row['making'].toString(), fontSize: 7.2),
                    _bodyCell(row['wastage'].toString(), fontSize: 7.2),
                    _bodyCell(row['stoneCost'].toString(), fontSize: 7.2),
                    _bodyCell(row['gstLabel'].toString()),
                    _bodyCell(amount(row['total'] as double), isBold: true),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 10),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 300,
              child: pw.Table(
                border: pw.TableBorder(
                  top: pw.BorderSide(color: summaryBorderColor, width: 1),
                  bottom: pw.BorderSide(color: summaryBorderColor, width: 1),
                  left: pw.BorderSide(color: summaryBorderColor, width: 1),
                  right: pw.BorderSide(color: summaryBorderColor, width: 1),
                  verticalInside: pw.BorderSide(
                    color: summaryDividerColor,
                    width: 1,
                  ),
                  horizontalInside: pw.BorderSide(
                    color: summaryDividerColor,
                    width: 1,
                  ),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.6),
                  1: const pw.FlexColumnWidth(1.1),
                },
                children: [
                  _summaryRow(
                    'Sub-total Including GST',
                    amount(subtotalIncludingGst),
                    borderColor: summaryBorderColor,
                  ),
                  _summaryRow(
                    'Making Charges',
                    amount(totalMaking),
                    borderColor: summaryBorderColor,
                  ),
                  _summaryRow(
                    'Total Gold Gross Weight (gm)',
                    weight(totalGrossWeight),
                    borderColor: summaryBorderColor,
                  ),
                  _summaryRow(
                    'Stone Cost',
                    amount(totalStoneCost),
                    borderColor: summaryBorderColor,
                  ),
                  _summaryRow(
                    'Wastage Charges',
                    amount(totalWastage),
                    borderColor: summaryBorderColor,
                  ),
                  _summaryRow(
                    'Total GST',
                    amount(totalGst),
                    borderColor: summaryBorderColor,
                  ),
                  _summaryRow(
                    'Grand Total',
                    amount(balanceGrandTotal),
                    highlight: true,
                    borderColor: summaryBorderColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _headerCell(String text, {double height = 40}) {
    return pw.Container(
      height: height,
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 8.0,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _bodyCell(
    String text, {
    bool isBold = false,
    double height = 30,
    double fontSize = 8.2,
  }) {
    return pw.Container(
      height: height,
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: PdfColors.black,
          height: 1.15,
        ),
      ),
    );
  }

  static pw.TableRow _summaryRow(
    String label,
    String value, {
    bool highlight = false,
    required PdfColor borderColor,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: highlight ? PdfColor.fromHex('#FBE9E7') : PdfColors.white,
        border: highlight
            ? pw.Border(
                top: pw.BorderSide(color: borderColor, width: 1),
              )
            : null,
      ),
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            label,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: highlight ? PdfColors.red900 : PdfColors.black,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: highlight ? PdfColors.red900 : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final rateList = ref.watch(goldRateProvider);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () async {
          final pdf = await buildEstimatePdf(items, rateList);

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PdfViewPage(pdf: pdf)),
          );
        },
        icon: const Icon(Icons.picture_as_pdf, size: 24),
        label: const Text(
          "Share Complete Estimate",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF002856),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}