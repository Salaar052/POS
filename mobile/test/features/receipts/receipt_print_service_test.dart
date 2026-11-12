import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/print_attempt_repository.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/data/repositories/receipt_settings_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/receipts/application/fake_thermal_printer_service.dart';
import 'package:pos_mobile/features/receipts/application/receipt_data_service.dart';
import 'package:pos_mobile/features/receipts/application/receipt_print_service.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

void main() {
  test('reprint logs attempt without changing sale', () async {
    final db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    final runner = DatabaseRunner(db);
    final fake = FakeThermalPrinterService();
    final settings = ReceiptSettingsRepository(runner);
    await settings.getSettings();
    final sales = SalesRepository(runner, receiptSettings: settings);
    final products = ProductRepository(runner);
    final product = await products.createProduct(
      name: 'Item',
      sku: 'S',
      costPriceMinor: 2000,
      sellingPriceMinor: 5000,
      unit: 'each',
    );
    await InventoryRepository(runner).recordOpeningStock(
      productId: product.id,
      quantityBase: 10,
      idempotencyKey: 'seed-stock',
    );
    final draft = await sales.createDraft(customerId: null);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: product.id,
      quantityBase: 1,
    );
    final completed = await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'ck',
      payments: [
        const CheckoutPaymentInput(
          method: SalePaymentMethod.cash,
          amountMinor: 5000,
          idempotencyKey: 'p',
        ),
      ],
    );
    final beforeUpdated = completed.updatedAtMs;

    final service = ReceiptPrintService(
      data: ReceiptDataService(runner),
      printer: fake,
      settings: settings,
      printAttempts: PrintAttemptRepository(runner),
    );
    final outcome = await service.printSaleReceipt(
      saleId: completed.id,
      printType: ReceiptPrintType.reprint,
    );
    expect(outcome.isSuccess, isTrue);
    expect(fake.printedJobs, isNotEmpty);

    final after = await sales.getSaleById(completed.id);
    expect(after?.invoiceNumber, completed.invoiceNumber);
    expect(after?.updatedAtMs, beforeUpdated);

    final attempts = await db.select(db.printAttempts).get();
    expect(attempts, hasLength(1));
    expect(attempts.first.printType, ReceiptPrintType.reprint.storage);
    await db.close();
  });
}
