import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/receipts/application/fake_thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/domain/printer_models.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';

void main() {
  test('native path uses printEscPos; PDF fallback uses printPdf', () async {
    final fake = FakeThermalPrinterService(
      discovered: const [
        DiscoveredPrinter(
          id: 'raw-1',
          displayName: 'Fake RAW',
          connectionType: PrinterConnectionType.windowsRawQueue,
          supportsEscPos: true,
        ),
      ],
    );
    await fake.connect(
      const PrinterConfiguration(
        printerId: 'raw-1',
        displayName: 'Fake RAW',
        connectionType: PrinterConnectionType.windowsRawQueue,
        paperWidth: ReceiptPaperWidth.mm58,
      ),
    );
    expect(fake.activeOutputChannel, ReceiptOutputChannel.nativeEscPos);

    final esc = Uint8List.fromList([0x1B, 0x40]);
    await fake.printEscPos(escPosBytes: esc, jobName: 'TEST', copyCount: 1);
    expect(fake.printedEscPosJobs, hasLength(1));

    await fake.connect(
      const PrinterConfiguration(
        printerId: 'pdf-1',
        displayName: 'System',
        connectionType: PrinterConnectionType.systemQueue,
        paperWidth: ReceiptPaperWidth.mm58,
      ),
    );
    expect(fake.activeOutputChannel, ReceiptOutputChannel.systemPdf);
    await fake.printPdf(pdfBytes: Uint8List(8), jobName: 'PDF', copyCount: 1);
    expect(fake.printedJobs, isNotEmpty);
  });
}
