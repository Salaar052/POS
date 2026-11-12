import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/data/repositories/receipt_settings_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
void main() {
  late AppDatabase db;
  late DatabaseRunner runner;
  late SalesRepository sales;
  late ProductRepository products;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    runner = DatabaseRunner(db);
    sales = SalesRepository(
      runner,
      receiptSettings: ReceiptSettingsRepository(runner),
    );
    products = ProductRepository(runner);
    await ReceiptSettingsRepository(runner).getSettings();
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> seedProduct() async {
    final row = await products.createProduct(
      name: 'Widget',
      sku: 'W1',
      costPriceMinor: 5000,
      sellingPriceMinor: 10000,
      unit: 'each',
    );
    await InventoryRepository(runner).recordOpeningStock(
      productId: row.id,
      quantityBase: 100,
      idempotencyKey: 'seed-${row.id}',
    );
    return row.id;
  }

  test(
    'completed sale receives sequential invoice numbers; drafts do not',
    () async {
      final productId = await seedProduct();
      final draft1 = await sales.createDraft(customerId: null);
      final draft2 = await sales.createDraft(customerId: null);
      await sales.addDraftItem(
        saleId: draft1.id,
        productId: productId,
        quantityBase: 1,
      );
      await sales.addDraftItem(
        saleId: draft2.id,
        productId: productId,
        quantityBase: 1,
      );

      final completed = await sales.checkout(
        saleId: draft1.id,
        checkoutIdempotencyKey: 'ck1',
        payments: [
          const CheckoutPaymentInput(
            method: SalePaymentMethod.cash,
            amountMinor: 10000,
            idempotencyKey: 'pay1',
          ),
        ],
      );
      expect(completed.invoiceNumber, matches(RegExp(r'^INV-\d{4}-\d{6}$')));

      final draft2Row = await sales.getSaleById(draft2.id);
      expect(draft2Row?.invoiceNumber, isNull);

      final completed2 = await sales.checkout(
        saleId: draft2.id,
        checkoutIdempotencyKey: 'ck2',
        payments: [
          const CheckoutPaymentInput(
            method: SalePaymentMethod.cash,
            amountMinor: 10000,
            idempotencyKey: 'pay2',
          ),
        ],
      );
      final n1 = int.parse(completed.invoiceNumber!.split('-').last);
      final n2 = int.parse(completed2.invoiceNumber!.split('-').last);
      expect(n2, n1 + 1);
    },
  );

  test('checkout idempotency does not allocate second invoice', () async {
    final productId = await seedProduct();
    final draft = await sales.createDraft(customerId: null);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: 1,
    );
    final first = await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'same-key',
      payments: [
        const CheckoutPaymentInput(
          method: SalePaymentMethod.cash,
          amountMinor: 10000,
          idempotencyKey: 'pay-a',
        ),
      ],
    );
    final second = await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'same-key',
      payments: [
        const CheckoutPaymentInput(
          method: SalePaymentMethod.cash,
          amountMinor: 10000,
          idempotencyKey: 'pay-a',
        ),
      ],
    );
    expect(second.invoiceNumber, first.invoiceNumber);
  });

  test('invoice sequence respects configured start', () async {
    await ReceiptSettingsRepository(runner).updateSettings(
      ReceiptSettingsCompanion(invoiceSequenceStart: const Value(100)),
    );
    final productId = await seedProduct();
    final draft = await sales.createDraft(customerId: null);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: 1,
    );
    final completed = await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'ck',
      payments: [
        const CheckoutPaymentInput(
          method: SalePaymentMethod.cash,
          amountMinor: 10000,
          idempotencyKey: 'pay',
        ),
      ],
    );
    expect(completed.invoiceNumber, endsWith('-000100'));
  });
}
