import 'dart:io';
import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:pos_mobile/features/receipts/application/esc_pos/esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/application/esc_pos/windows_raw_printer.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

class WindowsRawEscPosDevice implements EscPosDevice {
  PrinterConfiguration? _active;

  @override
  PrinterConnectionType get connectionType =>
      PrinterConnectionType.windowsRawQueue;

  @override
  Future<List<DiscoveredPrinter>> discover() async {
    if (!Platform.isWindows) {
      return [];
    }
    final printers = await Printing.listPrinters();
    return printers
        .map(
          (p) => DiscoveredPrinter(
            id: p.name,
            displayName: p.name,
            connectionType: PrinterConnectionType.windowsRawQueue,
            supportsEscPos: true,
          ),
        )
        .toList();
  }

  @override
  Future<void> connect(PrinterConfiguration configuration) async {
    if (configuration.connectionType != connectionType) {
      throw StateError('Wrong transport for Windows RAW printer');
    }
    _active = configuration;
  }

  @override
  Future<void> disconnect() async {
    _active = null;
  }

  @override
  Future<PrintOutcome> writeBytes(
    Uint8List bytes, {
    required int copyCount,
    required String jobName,
  }) async {
    final config = _active;
    if (config == null) {
      return const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'No Windows RAW printer connected',
      );
    }
    try {
      var any = false;
      for (var i = 0; i < copyCount; i++) {
        final ok = await WindowsRawPrinter.sendRawBytes(
          printerName: config.printerId,
          data: bytes,
          jobName: '$jobName${copyCount > 1 ? ' (${i + 1})' : ''}',
        );
        if (ok) {
          any = true;
        } else {
          return const PrintOutcome(
            result: ReceiptPrintResult.failed,
            message: 'Windows RAW WritePrinter failed',
          );
        }
      }
      if (any) {
        return const PrintOutcome(result: ReceiptPrintResult.success);
      }
      return const PrintOutcome(
        result: ReceiptPrintResult.unknown,
        message: 'RAW job completed without confirmation',
      );
    } catch (e) {
      return PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: e.toString(),
      );
    }
  }
}
