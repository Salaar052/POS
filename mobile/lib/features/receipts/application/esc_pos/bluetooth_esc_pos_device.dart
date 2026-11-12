import 'dart:io';
import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/application/esc_pos/esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// Bluetooth Classic ESC/POS via [print_bluetooth_thermal] (Android / Windows).
class BluetoothEscPosDevice implements EscPosDevice {
  PrinterConfiguration? _active;

  @override
  PrinterConnectionType get connectionType =>
      PrinterConnectionType.bluetoothClassic;

  @override
  Future<List<DiscoveredPrinter>> discover() async {
    if (!Platform.isAndroid && !Platform.isWindows) {
      return [];
    }
    try {
      if (Platform.isAndroid) {
        final granted =
            await PrintBluetoothThermal.isPermissionBluetoothGranted;
        if (!granted) {
          return [];
        }
      }
      final paired = await PrintBluetoothThermal.pairedBluetooths;
      return paired
          .map(
            (info) => DiscoveredPrinter(
              id: info.macAdress,
              displayName: info.name,
              connectionType: PrinterConnectionType.bluetoothClassic,
              supportsEscPos: true,
              paperWidthMm: 58,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> connect(PrinterConfiguration configuration) async {
    if (configuration.connectionType != connectionType) {
      throw StateError('Wrong transport for Bluetooth printer');
    }
    await PrintBluetoothThermal.disconnect;
    final ok = await PrintBluetoothThermal.connect(
      macPrinterAddress: configuration.printerId,
    );
    if (!ok) {
      throw StateError(
        'Bluetooth connection to ${configuration.displayName} failed',
      );
    }
    _active = configuration;
  }

  @override
  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
    _active = null;
  }

  @override
  Future<PrintOutcome> writeBytes(
    Uint8List bytes, {
    required int copyCount,
    required String jobName,
  }) async {
    if (_active == null) {
      return const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'Bluetooth printer not connected',
      );
    }
    try {
      final connected = await PrintBluetoothThermal.connectionStatus;
      if (!connected) {
        return const PrintOutcome(
          result: ReceiptPrintResult.failed,
          message: 'Bluetooth printer disconnected before print',
        );
      }
      for (var copy = 0; copy < copyCount; copy++) {
        final ok = await PrintBluetoothThermal.writeBytes(bytes);
        if (!ok) {
          return const PrintOutcome(
            result: ReceiptPrintResult.unknown,
            message:
                'Bluetooth writeBytes returned false; verify paper printed',
          );
        }
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
