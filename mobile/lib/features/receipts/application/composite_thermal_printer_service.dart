import 'dart:typed_data';

import 'package:pos_mobile/features/receipts/application/esc_pos/bluetooth_esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/application/esc_pos/esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/application/esc_pos/windows_raw_esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/application/esc_pos/windows_serial_esc_pos_device.dart';
import 'package:pos_mobile/features/receipts/application/system_queue_printer_service.dart';
import 'package:pos_mobile/features/receipts/application/thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/domain/printer_capabilities.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

/// Routes PDF jobs to the OS print dialog and ESC/POS bytes to native transports.
class CompositeThermalPrinterService implements ThermalPrinterService {
  CompositeThermalPrinterService({
    SystemQueuePrinterService? systemQueue,
    List<EscPosDevice>? escPosDevices,
  }) : _system = systemQueue ?? SystemQueuePrinterService(),
       _escPosDevices =
           escPosDevices ??
           [
             WindowsRawEscPosDevice(),
             WindowsSerialEscPosDevice(),
             BluetoothEscPosDevice(),
           ];

  final SystemQueuePrinterService _system;
  final List<EscPosDevice> _escPosDevices;
  EscPosDevice? _activeEscPos;
  PrinterConnectionState _escPosState = PrinterConnectionState.disconnected;

  EscPosDevice? _deviceFor(PrinterConnectionType type) {
    for (final d in _escPosDevices) {
      if (d.connectionType == type) {
        return d;
      }
    }
    return null;
  }

  @override
  PrinterConnectionState get connectionState {
    if (_activeEscPos != null) {
      return _escPosState;
    }
    return _system.connectionState;
  }

  @override
  PrinterConfiguration? get activeConfiguration {
    return _activeEscPos != null
        ? _activeConfigurationEscPos
        : _system.activeConfiguration;
  }

  PrinterConfiguration? _activeConfigurationEscPos;

  @override
  PrinterCapabilities? get activeCapabilities {
    final config = activeConfiguration;
    if (config == null) {
      return null;
    }
    if (config.connectionType == PrinterConnectionType.systemQueue) {
      return PrinterCapabilities.systemPdfOnly;
    }
    return PrinterCapabilities.escPosWithPdfFallback;
  }

  @override
  ReceiptOutputChannel get activeOutputChannel =>
      ReceiptOutputChannel.fromConnection(
        activeConfiguration?.connectionType ??
            PrinterConnectionType.systemQueue,
      );

  @override
  Future<List<DiscoveredPrinter>> discoverPrinters({
    PrinterConnectionType? transportFilter,
  }) async {
    final results = <DiscoveredPrinter>[];
    if (transportFilter == null ||
        transportFilter == PrinterConnectionType.systemQueue) {
      results.addAll(await _system.discoverPrinters());
    }
    for (final device in _escPosDevices) {
      if (transportFilter != null && transportFilter != device.connectionType) {
        continue;
      }
      try {
        results.addAll(await device.discover());
      } catch (_) {
        // Transport unavailable on this platform — omit from list.
      }
    }
    return results;
  }

  @override
  Future<void> connect(PrinterConfiguration configuration) async {
    if (configuration.connectionType == PrinterConnectionType.systemQueue) {
      await _disconnectEscPos();
      await _system.connect(configuration);
      return;
    }
    final device = _deviceFor(configuration.connectionType);
    if (device == null) {
      throw StateError(
        'Transport ${configuration.connectionType.storage} is not available',
      );
    }
    await _system.disconnect();
    _escPosState = PrinterConnectionState.connecting;
    try {
      await device.connect(configuration);
      _activeEscPos = device;
      _activeConfigurationEscPos = configuration;
      _escPosState = PrinterConnectionState.connected;
    } catch (e) {
      _escPosState = PrinterConnectionState.disconnected;
      _activeEscPos = null;
      _activeConfigurationEscPos = null;
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    await _disconnectEscPos();
    await _system.disconnect();
  }

  Future<void> _disconnectEscPos() async {
    final device = _activeEscPos;
    if (device != null) {
      await device.disconnect();
    }
    _activeEscPos = null;
    _activeConfigurationEscPos = null;
    _escPosState = PrinterConnectionState.disconnected;
  }

  @override
  Future<PrintOutcome> printPdf({
    required Uint8List pdfBytes,
    required String jobName,
    required int copyCount,
  }) async {
    if (_activeEscPos != null) {
      return const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'Active printer uses native ESC/POS. Switch to System PDF or reconnect.',
      );
    }
    return _system.printPdf(
      pdfBytes: pdfBytes,
      jobName: jobName,
      copyCount: copyCount,
    );
  }

  @override
  Future<PrintOutcome> printEscPos({
    required Uint8List escPosBytes,
    required String jobName,
    required int copyCount,
  }) async {
    final device = _activeEscPos;
    final config = _activeConfigurationEscPos;
    if (device == null || config == null) {
      return const PrintOutcome(
        result: ReceiptPrintResult.failed,
        message: 'No native ESC/POS printer connected',
      );
    }
    return device.writeBytes(
      escPosBytes,
      copyCount: copyCount,
      jobName: jobName,
    );
  }
}
