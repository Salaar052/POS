import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

class DiscoveredPrinter {
  const DiscoveredPrinter({
    required this.id,
    required this.displayName,
    required this.connectionType,
    this.supportsEscPos = false,
    this.paperWidthMm,
  });

  final String id;
  final String displayName;
  final PrinterConnectionType connectionType;
  final bool supportsEscPos;
  final int? paperWidthMm;
}

class PrinterConfiguration {
  const PrinterConfiguration({
    required this.printerId,
    required this.displayName,
    required this.connectionType,
    required this.paperWidth,
  });

  final String printerId;
  final String displayName;
  final PrinterConnectionType connectionType;
  final ReceiptPaperWidth paperWidth;
}

enum PrinterConnectionState { disconnected, connected, connecting }

class PrintOutcome {
  const PrintOutcome({required this.result, this.message});

  final ReceiptPrintResult result;
  final String? message;

  bool get isSuccess => result == ReceiptPrintResult.success;
}
