import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
/// Platform transport for receipt output (decoupled from sales/checkout).
abstract interface class ThermalPrinterService {
  Future<List<DiscoveredPrinter>> discoverPrinters();

  Future<void> connect(PrinterConfiguration configuration);

  Future<void> disconnect();

  PrinterConnectionState get connectionState;

  PrinterConfiguration? get activeConfiguration;

  Future<PrintOutcome> printPdf({
    required Uint8List pdfBytes,
    required String jobName,
    required int copyCount,
  });
}
