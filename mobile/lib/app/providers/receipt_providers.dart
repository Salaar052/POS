import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/print_attempt_repository.dart';
import 'package:pos_mobile/data/repositories/receipt_settings_repository.dart';
import 'package:pos_mobile/features/receipts/application/fake_thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/application/receipt_data_service.dart';
import 'package:pos_mobile/features/receipts/application/receipt_print_service.dart';
import 'package:pos_mobile/features/receipts/application/system_queue_printer_service.dart';
import 'package:pos_mobile/features/receipts/application/thermal_printer_service.dart';

final thermalPrinterServiceProvider = Provider<ThermalPrinterService>((ref) {
  return SystemQueuePrinterService();
});

final receiptSettingsRepositoryProvider = Provider<ReceiptSettingsRepository>(
  (ref) => ReceiptSettingsRepository(ref.watch(databaseRunnerProvider)),
);

final printAttemptRepositoryProvider = Provider<PrintAttemptRepository>(
  (ref) => PrintAttemptRepository(ref.watch(databaseRunnerProvider)),
);

final receiptDataServiceProvider = Provider<ReceiptDataService>((ref) {
  return ReceiptDataService(ref.watch(databaseRunnerProvider));
});

final receiptPrintServiceProvider = Provider<ReceiptPrintService>((ref) {
  return ReceiptPrintService(
    data: ref.watch(receiptDataServiceProvider),
    printer: ref.watch(thermalPrinterServiceProvider),
    settings: ref.watch(receiptSettingsRepositoryProvider),
    printAttempts: ref.watch(printAttemptRepositoryProvider),
  );
});

/// Overrides [thermalPrinterServiceProvider] in tests.
final fakeThermalPrinterServiceProvider = Provider<FakeThermalPrinterService>((
  ref,
) {
  return FakeThermalPrinterService();
});
