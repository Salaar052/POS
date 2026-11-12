import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

/// Platform device that accepts raw ESC/POS bytes.
abstract interface class EscPosDevice {
  PrinterConnectionType get connectionType;

  Future<List<DiscoveredPrinter>> discover();

  Future<void> connect(PrinterConfiguration configuration);

  Future<void> disconnect();

  Future<PrintOutcome> writeBytes(
    Uint8List bytes, {
    required int copyCount,
    required String jobName,
  });
}
