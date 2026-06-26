import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfViewPage extends StatelessWidget {
  final pw.Document pdf;

  const PdfViewPage({super.key, required this.pdf});

  Future<void> _sharePdf() async {
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'gold_bill_estimate.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gold Bill Estimate"),
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePdf,
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: PdfPreview(
        pdfPreviewPageDecoration: const BoxDecoration(
          color: Colors.white,
        ),
        build: (format) => pdf.save(),
        canChangePageFormat: false,
        canDebug: false,
        canChangeOrientation: false,
        allowPrinting: false,
        allowSharing: false,
        enableScrollToPage: true,
      ),
    );
  }
}