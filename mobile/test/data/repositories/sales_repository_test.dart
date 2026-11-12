import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  late CatalogTestHarness catalog;

  setUp(() async {
    catalog = await CatalogTestHarness.create();
  });

  tearDown(() async {
    await catalog.dispose();
  });

  Future<({String productId, String customerId})> seed() async {
    final customer = await CustomerRepository(catalog.runner)
        .createCustomer(name: 'POS Customer', phone: '03001234567');
    final product = await catalog.products.createProduct(
      name: 'Biscuits',
      costPriceMinor: 5000,
      sellingPriceMinor: 8000,
      unit: 'each',
    );
    return (productId: product.id, customerId: customer.id);
  }

  Future<void> stockIn(String productId, int qty) async {
    final supplier = await SupplierRepository(catalog.runner)
        .createSupplier(name: 'Stock Supplier');
    final purchases = PurchaseRepository(catalog.runner);
    final draft = await purchases.createDraft(supplierId: supplier.id);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: productId,
      quantityBase: qty,
      unitCostMinor: 100,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: const Uuid().v4(),
    );
  }

  test('draft does not affect stock', () async {
    final sales = SalesRepository(catalog.runner);
    final inventory = InventoryRepository(catalog.runner);
    final seeded = await seed();
    await stockIn(seeded.productId, 10);
    final draft = await sales.createDraft();
    await sales.addDraftItem(
      saleId: draft.id,
      productId: seeded.productId,
      quantityBase: 2,
    );
    expect(await inventory.getOnHandBase(seeded.productId), 10);
  });

  test('checkout reduces stock once and records receivable', () async {
    final sales = SalesRepository(catalog.runner);
    final inventory = InventoryRepository(catalog.runner);
    final ledger = CustomerLedgerRepository(catalog.runner);
    final seeded = await seed();
    await stockIn(seeded.productId, 5);
    final draft = await sales.createDraft(customerId: seeded.customerId);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: seeded.productId,
      quantityBase: 2,
    );
    const checkoutKey = 'checkout-1';
    const payKey = 'pay-1';
    await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: checkoutKey,
      payments: [
        const CheckoutPaymentInput(
          method: SalePaymentMethod.cash,
          amountMinor: 16000,
          idempotencyKey: payKey,
        ),
      ],
    );
    expect(await inventory.getOnHandBase(seeded.productId), 3);
    expect(await ledger.outstandingBalanceMinor(seeded.customerId), 0);
    final completed = await sales.getSaleById(draft.id);
    expect(completed?.status, SaleStatus.completed.storage);
    final dup = await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: checkoutKey,
      payments: const [],
    );
    expect(dup.id, draft.id);
    expect(await inventory.getOnHandBase(seeded.productId), 3);
  });

  test('walk-in requires full payment', () async {
    final sales = SalesRepository(catalog.runner);
    final seeded = await seed();
    await stockIn(seeded.productId, 5);
    final draft = await sales.createDraft();
    await sales.addDraftItem(
      saleId: draft.id,
      productId: seeded.productId,
      quantityBase: 1,
    );
    await expectLater(
      () => sales.checkout(
        saleId: draft.id,
        checkoutIdempotencyKey: 'w1',
        payments: const [
          CheckoutPaymentInput(
            method: SalePaymentMethod.cash,
            amountMinor: 1000,
            idempotencyKey: 'p1',
          ),
        ],
      ),
      throwsA(isA<SalesConflictException>()),
    );
  });

  test('return restores stock and credits customer', () async {
    final sales = SalesRepository(catalog.runner);
    final inventory = InventoryRepository(catalog.runner);
    final ledger = CustomerLedgerRepository(catalog.runner);
    final seeded = await seed();
    await stockIn(seeded.productId, 5);
    final draft = await sales.createDraft(customerId: seeded.customerId);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: seeded.productId,
      quantityBase: 2,
    );
    await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: 'c2',
      payments: const [],
    );
    expect(await ledger.outstandingBalanceMinor(seeded.customerId), 16000);
    final items = await sales.listSaleItems(draft.id);
    await sales.returnSale(
      saleId: draft.id,
      idempotencyKey: 'ret-1',
      reason: 'Defective',
      lines: [
        SaleReturnLineInput(saleItemId: items.single.id, quantityBase: 1),
      ],
    );
    expect(await inventory.getOnHandBase(seeded.productId), 4);
    expect(await ledger.outstandingBalanceMinor(seeded.customerId), 8000);
  });
}
