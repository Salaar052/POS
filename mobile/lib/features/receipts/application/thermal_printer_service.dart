import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/domain/printer_capabilities.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

/// Platform transport for receipt output (decoupled from sales/checkout).
abstract interface class ThermalPrinterService {
  Future<List<DiscoveredPrinter>> discoverPrinters({
    PrinterConnectionType? transportFilter,
  });

  Future<void> connect(PrinterConfiguration configuration);

  Future<void> disconnect();

  PrinterConnectionState get connectionState;

  PrinterConfiguration? get activeConfiguration;

  PrinterCapabilities? get activeCapabilities;

  ReceiptOutputChannel get activeOutputChannel;

  Future<PrintOutcome> printPdf({
    required Uint8List pdfBytes,
    required String jobName,
    required int copyCount,
  });

  Future<PrintOutcome> printEscPos({
    required Uint8List escPosBytes,
    required String jobName,
    required int copyCount,
  });
}
