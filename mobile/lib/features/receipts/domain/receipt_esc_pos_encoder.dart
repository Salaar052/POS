import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_text_layout.dart';

/// Builds ESC/POS byte streams from immutable receipt documents.
///
/// Text is limited to ASCII-compatible receipt content (Latin digits, PKR
/// labels). Urdu/Arabic is not emitted unless [PrinterCapabilities.unicodeReceiptText]
/// is validated on hardware.
abstract final class ReceiptEscPosEncoder {
  static Future<Uint8List> encodeSale({
    required ReceiptBusinessHeader business,
    required SaleReceiptDocument sale,
    required ReceiptRenderOptions options,
  }) async {
    final lines = ReceiptTextLayout.buildSaleReceipt(
      business: business,
      sale: sale,
      options: options,
    );
    return _encodeLines(
      lines: lines,
      paperWidth: options.paperWidth,
      titleBold: sale.isReprint ? 'REPRINT' : 'SALE RECEIPT',
    );
  }

  static Future<Uint8List> encodeReturn({
    required ReceiptBusinessHeader business,
    required ReturnReceiptDocument doc,
    required ReceiptPaperWidth paperWidth,
  }) async {
    final lines = ReceiptTextLayout.buildReturnReceipt(
      business: business,
      doc: doc,
      paperWidth: paperWidth,
    );
    return _encodeLines(
      lines: lines,
      paperWidth: paperWidth,
      titleBold: doc.isReprint ? 'RETURN REPRINT' : 'RETURN RECEIPT',
    );
  }

  static Future<Uint8List> encodeTest({
    required ReceiptBusinessHeader business,
    required ReceiptPaperWidth paperWidth,
  }) async {
    final lines = [
      '--- TEST RECEIPT ---',
      business.displayName ?? 'Your Business',
      'Paper: ${paperWidth.mm}mm',
      'ESC/POS encoding test',
      'If this prints, native thermal works.',
      '',
    ];
    return _encodeLines(
      lines: lines,
      paperWidth: paperWidth,
      titleBold: 'TEST',
    );
  }

  static Future<Uint8List> _encodeLines({
    required List<String> lines,
    required ReceiptPaperWidth paperWidth,
    required String titleBold,
  }) async {
    final profile = await CapabilityProfile.load();
    final paperSize = paperWidth == ReceiptPaperWidth.mm80
        ? PaperSize.mm80
        : PaperSize.mm58;
    final generator = Generator(paperSize, profile);
    var bytes = <int>[];

    bytes += generator.reset();
    bytes += generator.setGlobalCodeTable('CP437');

    for (final raw in lines) {
      final line = _toAsciiSafe(raw);
      if (line.isEmpty) {
        bytes += generator.feed(1);
        continue;
      }
      final trimmed = line.trim();
      final isTitle =
          trimmed == titleBold ||
          trimmed == 'REPRINT' ||
          trimmed == 'SALE RECEIPT' ||
          trimmed == 'RETURN RECEIPT' ||
          trimmed == 'RETURN REPRINT';
      final isTotal =
          trimmed.startsWith('TOTAL') ||
          trimmed.startsWith('Return total') ||
          trimmed.startsWith('Balance due');
      final style = PosStyles(
        bold: isTitle || isTotal,
        align: _guessAlign(line, trimmed),
      );
      bytes += generator.text(trimmed, styles: style);
    }

    bytes += generator.feed(2);
    return Uint8List.fromList(bytes);
  }

  static PosAlign _guessAlign(String raw, String trimmed) {
    if (trimmed.isEmpty) {
      return PosAlign.left;
    }
    if (raw.startsWith(' ') && !raw.startsWith('  ')) {
      return PosAlign.center;
    }
    if (raw == trimmed &&
        raw.length < ReceiptTextLayout.charsPerLine(ReceiptPaperWidth.mm80)) {
      final padded = raw.padLeft(
        (ReceiptTextLayout.charsPerLine(ReceiptPaperWidth.mm58) + raw.length) ~/
            2,
      );
      if (padded == raw) {
        return PosAlign.center;
      }
    }
    return PosAlign.left;
  }

  /// Strips unsupported characters for CP437 thermal output.
  static String _toAsciiSafe(String input) {
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      if (codeUnit >= 32 && codeUnit <= 126) {
        buffer.writeCharCode(codeUnit);
      } else if (codeUnit == 10 || codeUnit == 13) {
        continue;
      } else {
        buffer.write('?');
      }
    }
    return buffer.toString();
  }
}
