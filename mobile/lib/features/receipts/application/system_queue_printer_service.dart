import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:pos_mobile/features/receipts/application/thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/domain/printer_capabilities.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_pdf_builder.dart';

/// Uses the OS print dialog (Windows spooler / Android print framework).
///
/// PDF/system dialog only — native ESC/POS uses [CompositeThermalPrinterService].
class SystemQueuePrinterService implements ThermalPrinterService {
  PrinterConnectionState _state = PrinterConnectionState.disconnected;
  PrinterConfiguration? _config;

  @override
  PrinterConnectionState get connectionState => _state;

  @override
  PrinterConfiguration? get activeConfiguration => _config;

  @override
  PrinterCapabilities? get activeCapabilities =>
      _config == null ? null : PrinterCapabilities.systemPdfOnly;

  @override
  ReceiptOutputChannel get activeOutputChannel =>
      ReceiptOutputChannel.systemPdf;

  @override
  Future<List<DiscoveredPrinter>> discoverPrinters({
    PrinterConnectionType? transportFilter,
  }) async {
    if (transportFilter != null &&
        transportFilter != PrinterConnectionType.systemQueue) {
      return [];
    }
    try {
      final printers = await Printing.listPrinters();
      if (printers.isEmpty) {
        return [
          const DiscoveredPrinter(
            id: 'system-default',
            displayName: 'System default printer',
            connectionType: PrinterConnectionType.systemQueue,
          ),
        ];
      }
      return printers
          .map(
            (p) => DiscoveredPrinter(
              id: p.name,
              displayName: p.name,
              connectionType: PrinterConnectionType.systemQueue,
              supportsEscPos: false,
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Printer discovery failed: $e');
      }
      return [
        const DiscoveredPrinter(
          id: 'system-default',
          displayName: 'System default printer',
          connectionType: PrinterConnectionType.systemQueue,
        ),
      ];
    }
  }

  @override
  Future<void> connect(PrinterConfiguration configuration) async {
    _config = configuration;
    _state = PrinterConnectionState.connected;
  }

  @override
  Future<void> disconnect() async {
    _config = null;
    _state = PrinterConnectionState.disconnected;
  }

  @override
  Future<PrintOutcome> printPdf({
    required Uint8List pdfBytes,
    required String jobName,
    required int copyCount,
  }) async {
    final paper = _config?.paperWidth ?? ReceiptPaperWidth.mm58;
    final format = ReceiptPdfBuilder.pageFormatFor(paper);
    try {
      var anyPrinted = false;
      for (var copy = 0; copy < copyCount; copy++) {
        final printed = await Printing.layoutPdf(
          name: '$jobName${copyCount > 1 ? ' (${copy + 1}/$copyCount)' : ''}',
          format: format,
          onLayout: (_) async => pdfBytes,
        );
        if (printed) {
          anyPrinted = true;
        }
      }
      if (anyPrinted) {
        return const PrintOutcome(result: ReceiptPrintResult.success);
      }
      return const PrintOutcome(
        result: ReceiptPrintResult.unknown,
        message: 'Print dialog closed without confirmation.',
      );
    } catch (e) {
      return PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: e.toString(),
      );
    }
  }

  @override
  Future<PrintOutcome> printEscPos({
    required Uint8List escPosBytes,
    required String jobName,
    required int copyCount,
  }) async {
    return const PrintOutcome(
      result: ReceiptPrintResult.failed,
      message: 'System PDF transport cannot send ESC/POS bytes',
    );
  }
}
