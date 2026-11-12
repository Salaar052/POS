import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/application/thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

class FakeThermalPrinterService implements ThermalPrinterService {
  FakeThermalPrinterService({
    this.discovered = const [
      DiscoveredPrinter(
        id: 'fake-1',
        displayName: 'Fake Thermal',
        connectionType: PrinterConnectionType.systemQueue,
        paperWidthMm: 58,
      ),
    ],
    this.failNextPrint = false,
    this.ambiguousNextPrint = false,
  });

  List<DiscoveredPrinter> discovered;
  bool failNextPrint;
  bool ambiguousNextPrint;
  @override
  PrinterConnectionState connectionState = PrinterConnectionState.disconnected;
  @override
  PrinterConfiguration? activeConfiguration;

  final List<Uint8List> printedJobs = [];

  @override
  Future<List<DiscoveredPrinter>> discoverPrinters() async => discovered;

  @override
  Future<void> connect(PrinterConfiguration configuration) async {
    activeConfiguration = configuration;
    connectionState = PrinterConnectionState.connected;
  }

  @override
  Future<void> disconnect() async {
    activeConfiguration = null;
    connectionState = PrinterConnectionState.disconnected;
  }

  @override
  Future<PrintOutcome> printPdf({
    required Uint8List pdfBytes,
    required String jobName,
    required int copyCount,
  }) async {
    if (failNextPrint) {
      failNextPrint = false;
      return const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'Simulated failure',
      );
    }
    if (ambiguousNextPrint) {
      ambiguousNextPrint = false;
      printedJobs.add(pdfBytes);
      return const PrintOutcome(
        result: ReceiptPrintResult.unknown,
        message: 'Simulated ambiguous outcome',
      );
    }
    for (var i = 0; i < copyCount; i++) {
      printedJobs.add(pdfBytes);
    }
    return const PrintOutcome(result: ReceiptPrintResult.success);
  }
}
