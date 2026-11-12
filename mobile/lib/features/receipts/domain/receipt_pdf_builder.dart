import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_text_layout.dart';

abstract final class ReceiptPdfBuilder {
  static PdfPageFormat pageFormatFor(ReceiptPaperWidth width) {
    final mm = width.mm.toDouble();
    return PdfPageFormat(mm * PdfPageFormat.mm, double.infinity, marginAll: 4);
  }

  static Future<Uint8List> buildSalePdf({
    required ReceiptBusinessHeader business,
    required SaleReceiptDocument sale,
    required ReceiptRenderOptions options,
  }) async {
    final lines = ReceiptTextLayout.buildSaleReceipt(
      business: business,
      sale: sale,
      options: options,
    );
    return _linesToPdf(lines, pageFormatFor(options.paperWidth));
  }

  static Future<Uint8List> buildReturnPdf({
    required ReceiptBusinessHeader business,
    required ReturnReceiptDocument doc,
    required ReceiptPaperWidth paperWidth,
  }) async {
    final lines = ReceiptTextLayout.buildReturnReceipt(
      business: business,
      doc: doc,
      paperWidth: paperWidth,
    );
    return _linesToPdf(lines, pageFormatFor(paperWidth));
  }

  static Future<Uint8List> buildTestPdf({
    required ReceiptBusinessHeader business,
    required ReceiptPaperWidth paperWidth,
  }) async {
    final lines = [
      '--- TEST RECEIPT ---',
      business.displayName ?? 'Your Business',
      'Paper: ${paperWidth.mm}mm',
      'If you can read this, printing works.',
      '',
    ];
    return _linesToPdf(lines, pageFormatFor(paperWidth));
  }

  static Future<Uint8List> _linesToPdf(
    List<String> lines,
    PdfPageFormat format,
  ) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final line in lines)
                pw.Text(line, style: const pw.TextStyle(fontSize: 9)),
            ],
          );
        },
      ),
    );
    return doc.save();
  }
}
