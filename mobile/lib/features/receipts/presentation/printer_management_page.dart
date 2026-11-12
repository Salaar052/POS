import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/providers/receipt_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

class PrinterManagementPage extends ConsumerStatefulWidget {
  const PrinterManagementPage({super.key});

  @override
  ConsumerState<PrinterManagementPage> createState() =>
      _PrinterManagementPageState();
}

class _PrinterManagementPageState extends ConsumerState<PrinterManagementPage> {
  List<DiscoveredPrinter> _printers = [];
  bool _discovering = false;
  String? _error;
  int _paperWidth = 58;
  PrinterConnectionType? _transportFilter;
  final _manualSerialController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _manualSerialController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final settings = await ref
        .read(receiptSettingsRepositoryProvider)
        .getSettings();
    setState(() => _paperWidth = settings.paperWidthMm);
    await _discover();
    final printer = ref.read(thermalPrinterServiceProvider);
    if (settings.selectedPrinterId != null) {
      await printer.connect(
        PrinterConfiguration(
          printerId: settings.selectedPrinterId!,
          displayName:
              settings.printerDisplayName ?? settings.selectedPrinterId!,
          connectionType: PrinterConnectionType.parse(
            settings.printerConnectionType,
          ),
          paperWidth: ReceiptPaperWidth.fromMm(settings.paperWidthMm),
        ),
      );
    }
  }

  Future<void> _discover() async {
    setState(() {
      _discovering = true;
      _error = null;
    });
    try {
      final list = await ref
          .read(thermalPrinterServiceProvider)
          .discoverPrinters(transportFilter: _transportFilter);
      setState(() {
        _printers = list;
        _discovering = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _discovering = false;
      });
    }
  }

  Future<void> _selectPrinter(DiscoveredPrinter printer) async {
    final service = ref.read(thermalPrinterServiceProvider);
    final config = PrinterConfiguration(
      printerId: printer.id,
      displayName: printer.displayName,
      connectionType: printer.connectionType,
      paperWidth: ReceiptPaperWidth.fromMm(_paperWidth),
    );
    try {
      await service.connect(config);
      await ref
          .read(receiptSettingsRepositoryProvider)
          .updateSettings(
            ReceiptSettingsCompanion(
              selectedPrinterId: Value(printer.id),
              printerDisplayName: Value(printer.displayName),
              printerConnectionType: Value(printer.connectionType.storage),
              paperWidthMm: Value(_paperWidth),
            ),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${printer.displayName}')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Connection failed: $e')));
    }
  }

  Future<void> _testPrint({bool forceSystemPdf = false}) async {
    final outcome = await ref
        .read(receiptPrintServiceProvider)
        .printTestReceipt(forceSystemPdf: forceSystemPdf);
    if (!mounted) {
      return;
    }
    final message = switch (outcome.result) {
      ReceiptPrintResult.success => 'Test receipt sent to printer.',
      ReceiptPrintResult.failed => outcome.message ?? 'Print failed.',
      ReceiptPrintResult.unknown =>
        outcome.message ??
            'Print result uncertain — check the printer before retrying.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _disconnect() async {
    await ref.read(thermalPrinterServiceProvider).disconnect();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final printer = ref.watch(thermalPrinterServiceProvider);
    final connected =
        printer.connectionState == PrinterConnectionState.connected;
    final active = printer.activeConfiguration;

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'Printer',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Choose System PDF for the OS print dialog, or a native transport '
              'for raw ESC/POS. You can always fall back to PDF if native printing fails.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: ListTile(
                leading: Icon(
                  connected ? Icons.print : Icons.print_disabled,
                  color: connected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(connected ? 'Connected' : 'Not connected'),
                subtitle: Text(
                  active == null
                      ? 'No printer selected'
                      : '${active.displayName} · ${printer.activeOutputChannel.storage}',
                ),
              ),
            ),
            if (printer.activeCapabilities != null)
              Card(
                child: ListTile(
                  title: const Text('Capabilities'),
                  subtitle: Text(
                    'ESC/POS: ${printer.activeCapabilities!.supportsEscPos} · '
                    'PDF: ${printer.activeCapabilities!.supportsPdf} · '
                    'Encoding: ${printer.activeCapabilities!.characterEncoding}',
                  ),
                ),
              ),
            DropdownButtonFormField<PrinterConnectionType?>(
              value: _transportFilter,
              decoration: const InputDecoration(labelText: 'Transport filter'),
              items: const [
                DropdownMenuItem(value: null, child: Text('All transports')),
                DropdownMenuItem(
                  value: PrinterConnectionType.systemQueue,
                  child: Text('System PDF'),
                ),
                DropdownMenuItem(
                  value: PrinterConnectionType.windowsRawQueue,
                  child: Text('Windows RAW queue'),
                ),
                DropdownMenuItem(
                  value: PrinterConnectionType.windowsSerial,
                  child: Text('Windows serial (COM)'),
                ),
                DropdownMenuItem(
                  value: PrinterConnectionType.bluetoothClassic,
                  child: Text('Bluetooth Classic'),
                ),
              ],
              onChanged: (v) async {
                setState(() => _transportFilter = v);
                await _discover();
              },
            ),
            DropdownButtonFormField<int>(
              value: _paperWidth,
              decoration: const InputDecoration(labelText: 'Paper width'),
              items: const [
                DropdownMenuItem(value: 58, child: Text('58 mm')),
                DropdownMenuItem(value: 80, child: Text('80 mm')),
              ],
              onChanged: (v) async {
                setState(() => _paperWidth = v ?? 58);
                if (active != null) {
                  await _selectPrinter(
                    DiscoveredPrinter(
                      id: active.printerId,
                      displayName: active.displayName,
                      connectionType: active.connectionType,
                      paperWidthMm: _paperWidth,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: _discovering ? null : _discover,
                  child: _discovering
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Discover printers'),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (connected)
                  TextButton(
                    onPressed: _disconnect,
                    child: const Text('Disconnect'),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ..._printers.map(
              (p) => Card(
                child: ListTile(
                  title: Text(p.displayName),
                  subtitle: Text(p.connectionType.storage),
                  trailing: active?.printerId == p.id
                      ? const Icon(Icons.check_circle)
                      : null,
                  onTap: () => _selectPrinter(p),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _manualSerialController,
              decoration: const InputDecoration(
                labelText: 'Manual COM port (e.g. COM4)',
                helperText:
                    'Discover serial ports or enter a port name manually.',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () {
                final port = _manualSerialController.text.trim();
                if (port.isEmpty) {
                  return;
                }
                _selectPrinter(
                  DiscoveredPrinter(
                    id: port,
                    displayName: 'Serial $port',
                    connectionType: PrinterConnectionType.windowsSerial,
                    supportsEscPos: true,
                  ),
                );
              },
              child: const Text('Connect manual serial'),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: connected ? () => _testPrint() : null,
              child: const Text('Print test (active transport)'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: () => _testPrint(forceSystemPdf: true),
              child: const Text('Print test using PDF fallback'),
            ),
          ],
        ),
      ),
    );
  }
}
