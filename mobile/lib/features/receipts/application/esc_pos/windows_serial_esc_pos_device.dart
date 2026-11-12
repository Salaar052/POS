import 'dart:io';
import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/application/esc_pos/esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

class WindowsSerialEscPosDevice implements EscPosDevice {
  RandomAccessFile? _file;

  @override
  PrinterConnectionType get connectionType =>
      PrinterConnectionType.windowsSerial;

  static List<String> _listComPorts() {
    if (!Platform.isWindows) {
      return [];
    }
    final ports = <String>[];
    for (var i = 1; i <= 32; i++) {
      ports.add('COM$i');
    }
    return ports;
  }

  @override
  Future<List<DiscoveredPrinter>> discover() async {
    if (!Platform.isWindows) {
      return [];
    }
    // Windows does not expose a stable COM enumeration API in Dart; list
    // common names for operator selection (connect validates the port).
    return _listComPorts()
        .map(
          (name) => DiscoveredPrinter(
            id: name,
            displayName: 'Serial $name (try connect)',
            connectionType: PrinterConnectionType.windowsSerial,
            supportsEscPos: true,
            paperWidthMm: 58,
          ),
        )
        .toList();
  }

  static String _comPath(String port) => r'\\.\' + port;

  @override
  Future<void> connect(PrinterConfiguration configuration) async {
    if (configuration.connectionType != connectionType) {
      throw StateError('Wrong transport for serial printer');
    }
    await disconnect();
    final file = await File(_comPath(configuration.printerId)).open(
      mode: FileMode.write,
    );
    _file = file;
  }

  @override
  Future<void> disconnect() async {
    await _file?.close();
    _file = null;
  }

  @override
  Future<PrintOutcome> writeBytes(
    Uint8List bytes, {
    required int copyCount,
    required String jobName,
  }) async {
    final file = _file;
    if (file == null) {
      return const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'Serial port not connected',
      );
    }
    try {
      for (var copy = 0; copy < copyCount; copy++) {
        await file.writeFrom(bytes);
        await file.flush();
      }
      return const PrintOutcome(result: ReceiptPrintResult.success);
    } catch (e) {
      return PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: e.toString(),
      );
    }
  }
}
