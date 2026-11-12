import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:uuid/uuid.dart';

import '../../fakes/failing_customer_ledger_repository.dart';
import '../../fakes/failing_inventory_repository.dart';
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
        .createCustomer(name: 'Integrity Customer');
    final product = await catalog.products.createProduct(
      name: 'Widget',
      costPriceMinor: 100,
      sellingPriceMinor: 1000,
      unit: 'each',
    );
    return (productId: product.id, customerId: customer.id);
  }

  Future<void> stockIn(String productId, int qty) async {
    final supplier = await SupplierRepository(catalog.runner)
        .createSupplier(name: 'Supplier');
    final purchases = PurchaseRepository(catalog.runner);
    final draft = await purchases.createDraft(supplierId: supplier.id);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: productId,
      quantityBase: qty,
      unitCostMinor: 50,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: const Uuid().v4(),
    );
  }

  Future<String> completedSale({
    required String productId,
    required String customerId,
    int qty = 3,
    String checkoutKey = 'co',
    String paymentKey = 'pay',
    int paymentMinor = 0,
  }) async {
    await stockIn(productId, qty);
    final sales = SalesRepository(catalog.runner);
    final draft = await sales.createDraft(customerId: customerId);
    await sales.addDraftItem(
      saleId: draft.id,
      productId: productId,
      quantityBase: qty,
    );
    await sales.checkout(
      saleId: draft.id,
      checkoutIdempotencyKey: checkoutKey,
      payments: paymentMinor > 0
          ? [
              CheckoutPaymentInput(
                method: SalePaymentMethod.cash,
                amountMinor: paymentMinor,
                idempotencyKey: paymentKey,
              ),
            ]
          : const [],
    );
    return draft.id;
  }

  group('return duplicate lines', () {
    test('aggregated duplicate lines within limit succeed', () async {
      final seeded = await seed();
      final saleId = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        checkoutKey: 'r1',
      );
      final items = await SalesRepository(catalog.runner).listSaleItems(saleId);
      final itemId = items.single.id;
      await SalesRepository(catalog.runner).returnSale(
        saleId: saleId,
        idempotencyKey: 'ret-dup-ok',
        reason: 'ok',
        lines: [
          SaleReturnLineInput(saleItemId: itemId, quantityBase: 1),
          SaleReturnLineInput(saleItemId: itemId, quantityBase: 1),
        ],
      );
      final itemAfter = await SalesRepository(catalog.runner)
          .getSaleItemById(itemId);
      expect(itemAfter?.quantityReturnedBase, 2);
    });

    test('aggregated duplicate lines exceeding sold qty rejected', () async {
      final seeded = await seed();
      final saleId = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        qty: 2,
        checkoutKey: 'r2',
      );
      final items = await SalesRepository(catalog.runner).listSaleItems(saleId);
      final itemId = items.single.id;
      final inventory = InventoryRepository(catalog.runner);
      final onHandBefore = await inventory.getOnHandBase(seeded.productId);
      await expectLater(
        () => SalesRepository(catalog.runner).returnSale(
          saleId: saleId,
          idempotencyKey: 'ret-dup-bad',
          reason: 'bad',
          lines: [
            SaleReturnLineInput(saleItemId: itemId, quantityBase: 1),
            SaleReturnLineInput(saleItemId: itemId, quantityBase: 2),
          ],
        ),
        throwsA(isA<SalesConflictException>()),
      );
      expect(await inventory.getOnHandBase(seeded.productId), onHandBefore);
      final itemAfter = await SalesRepository(catalog.runner)
          .getSaleItemById(itemId);
      expect(itemAfter?.quantityReturnedBase, 0);
    });

    test('partial return then valid second return', () async {
      final seeded = await seed();
      final saleId = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        qty: 3,
        checkoutKey: 'r3',
      );
      final itemId = (await SalesRepository(
        catalog.runner,
      ).listSaleItems(saleId)).single.id;
      final sales = SalesRepository(catalog.runner);
      await sales.returnSale(
        saleId: saleId,
        idempotencyKey: 'ret-partial',
        reason: 'first',
        lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
      );
      await sales.returnSale(
        saleId: saleId,
        idempotencyKey: 'ret-partial-2',
        reason: 'second',
        lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
      );
      final itemAfter = await sales.getSaleItemById(itemId);
      expect(itemAfter?.quantityReturnedBase, 2);
    });
  });

  group('checkout payment idempotency', () {
    test('retry identical checkout does not duplicate payments', () async {
      final seeded = await seed();
      await stockIn(seeded.productId, 5);
      final sales = SalesRepository(catalog.runner);
      final draft = await sales.createDraft(customerId: seeded.customerId);
      await sales.addDraftItem(
        saleId: draft.id,
        productId: seeded.productId,
        quantityBase: 1,
      );
      const checkoutKey = 'idem-co';
      const payKey = 'idem-pay';
      await sales.checkout(
        saleId: draft.id,
        checkoutIdempotencyKey: checkoutKey,
        payments: const [
          CheckoutPaymentInput(
            method: SalePaymentMethod.cash,
            amountMinor: 1000,
            idempotencyKey: payKey,
          ),
        ],
      );
      await sales.checkout(
        saleId: draft.id,
        checkoutIdempotencyKey: checkoutKey,
        payments: const [
          CheckoutPaymentInput(
            method: SalePaymentMethod.cash,
            amountMinor: 1000,
            idempotencyKey: payKey,
          ),
        ],
      );
      final payments = await sales.listSalePayments(draft.id);
      expect(payments, hasLength(1));
      final sale = await sales.getSaleById(draft.id);
      expect(sale?.amountPaidMinor, 1000);
      expect(sale?.amountDueMinor, 0);
    });

    test('reused payment key on another sale rejected', () async {
      final seeded = await seed();
      await stockIn(seeded.productId, 10);
      final sales = SalesRepository(catalog.runner);
      final draft1 = await sales.createDraft();
      await sales.addDraftItem(
        saleId: draft1.id,
        productId: seeded.productId,
        quantityBase: 1,
      );
      const payKey = 'shared-pay-key';
      await sales.checkout(
        saleId: draft1.id,
        checkoutIdempotencyKey: 's1',
        payments: const [
          CheckoutPaymentInput(
            method: SalePaymentMethod.cash,
            amountMinor: 1000,
            idempotencyKey: payKey,
          ),
        ],
      );
      final draft2 = await sales.createDraft();
      await sales.addDraftItem(
        saleId: draft2.id,
        productId: seeded.productId,
        quantityBase: 1,
      );
      await expectLater(
        () => sales.checkout(
          saleId: draft2.id,
          checkoutIdempotencyKey: 's2',
          payments: const [
            CheckoutPaymentInput(
              method: SalePaymentMethod.cash,
              amountMinor: 1000,
              idempotencyKey: payKey,
            ),
          ],
        ),
        throwsA(
          predicate<SalesConflictException>(
            (e) => e.code == SalesConflictCode.idempotencyConflict,
          ),
        ),
      );
      expect(
        (await sales.getSaleById(draft2.id))?.status,
        SaleStatus.draft.storage,
      );
    });

    test('reused payment key with different amount rejected', () async {
      final seeded = await seed();
      await stockIn(seeded.productId, 5);
      final sales = SalesRepository(catalog.runner);
      final draft = await sales.createDraft(customerId: seeded.customerId);
      await sales.addDraftItem(
        saleId: draft.id,
        productId: seeded.productId,
        quantityBase: 1,
      );
      const payKey = 'amt-key';
      await expectLater(
        () => sales.checkout(
          saleId: draft.id,
          checkoutIdempotencyKey: 'one',
          payments: [
            CheckoutPaymentInput(
              method: SalePaymentMethod.cash,
              amountMinor: 1000,
              idempotencyKey: payKey,
            ),
            CheckoutPaymentInput(
              method: SalePaymentMethod.cash,
              amountMinor: 500,
              idempotencyKey: payKey,
            ),
          ],
        ),
        throwsA(isA<SalesConflictException>()),
      );
      expect((await sales.listSalePayments(draft.id)), isEmpty);
    });
  });

  group('return idempotency', () {
    test('identical return request is idempotent', () async {
      final seeded = await seed();
      final saleId = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        qty: 2,
        checkoutKey: 'rid',
      );
      final itemId = (await SalesRepository(
        catalog.runner,
      ).listSaleItems(saleId)).single.id;
      final sales = SalesRepository(catalog.runner);
      const key = 'ret-idem';
      final first = await sales.returnSale(
        saleId: saleId,
        idempotencyKey: key,
        reason: 'same',
        lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
      );
      final second = await sales.returnSale(
        saleId: saleId,
        idempotencyKey: key,
        reason: 'same',
        lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
      );
      expect(second.id, first.id);
      final returns = await catalog.harness.database
          .select(catalog.harness.database.saleReturns)
          .get();
      expect(returns, hasLength(1));
    });

    test('return key for different sale rejected', () async {
      final seeded = await seed();
      final sale1 = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        checkoutKey: 'a',
      );
      final sale2 = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        checkoutKey: 'b',
      );
      final item1 = (await SalesRepository(catalog.runner).listSaleItems(sale1))
          .single
          .id;
      final sales = SalesRepository(catalog.runner);
      const key = 'cross-sale';
      await sales.returnSale(
        saleId: sale1,
        idempotencyKey: key,
        reason: 'r',
        lines: [SaleReturnLineInput(saleItemId: item1, quantityBase: 1)],
      );
      final item2 = (await SalesRepository(catalog.runner).listSaleItems(sale2))
          .single
          .id;
      await expectLater(
        () => sales.returnSale(
          saleId: sale2,
          idempotencyKey: key,
          reason: 'r',
          lines: [SaleReturnLineInput(saleItemId: item2, quantityBase: 1)],
        ),
        throwsA(
          predicate<SalesConflictException>(
            (e) => e.code == SalesConflictCode.idempotencyConflict,
          ),
        ),
      );
    });
  });

  group('checkout rollback', () {
    test('inventory failure leaves draft and stock unchanged', () async {
      final seeded = await seed();
      await stockIn(seeded.productId, 5);
      final inventory = FailingInventoryRepository(
        catalog.runner,
        failOnMovementType: StockMovementType.sale,
      );
      final sales = SalesRepository(catalog.runner, inventory: inventory);
      final draft = await sales.createDraft();
      await sales.addDraftItem(
        saleId: draft.id,
        productId: seeded.productId,
        quantityBase: 2,
      );
      await expectLater(
        () => sales.checkout(
          saleId: draft.id,
          checkoutIdempotencyKey: 'fail-inv',
          payments: const [
            CheckoutPaymentInput(
              method: SalePaymentMethod.cash,
              amountMinor: 2000,
              idempotencyKey: 'fail-pay',
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        (await sales.getSaleById(draft.id))?.status,
        SaleStatus.draft.storage,
      );
      expect(
        await InventoryRepository(catalog.runner)
            .getOnHandBase(seeded.productId),
        5,
      );
      expect((await sales.listSalePayments(draft.id)), isEmpty);
    });

    test('ledger failure rolls back stock and payments', () async {
      final seeded = await seed();
      await stockIn(seeded.productId, 5);
      final ledger = FailingCustomerLedgerRepository(
        catalog.runner,
        failOnType: CustomerLedgerEntryType.saleReceivable,
      );
      final sales = SalesRepository(catalog.runner, ledger: ledger);
      final draft = await sales.createDraft(customerId: seeded.customerId);
      await sales.addDraftItem(
        saleId: draft.id,
        productId: seeded.productId,
        quantityBase: 1,
      );
      await expectLater(
        () => sales.checkout(
          saleId: draft.id,
          checkoutIdempotencyKey: 'fail-ledger',
          payments: const [
            CheckoutPaymentInput(
              method: SalePaymentMethod.cash,
              amountMinor: 500,
              idempotencyKey: 'fail-ledger-pay',
            ),
          ],
        ),
        throwsA(isA<SalesConflictException>()),
      );
      expect(
        (await sales.getSaleById(draft.id))?.status,
        SaleStatus.draft.storage,
      );
      expect(
        await InventoryRepository(catalog.runner)
            .getOnHandBase(seeded.productId),
        5,
      );
      expect((await sales.listSalePayments(draft.id)), isEmpty);
      expect(
        await CustomerLedgerRepository(catalog.runner)
            .outstandingBalanceMinor(seeded.customerId),
        0,
      );
    });
  });

  Future<void> assertReturnStateClean({
    required String saleId,
    required String productId,
    required String customerId,
    required int expectedOnHand,
    required int expectedReturnedBase,
  }) async {
    final db = catalog.harness.database;
    expect(await db.select(db.saleReturns).get(), isEmpty);
    expect(await db.select(db.saleReturnItems).get(), isEmpty);
    final movements = await db.select(db.stockMovements).get();
    expect(
      movements.where(
        (m) => m.movementType == StockMovementType.saleReturn.storageValue,
      ),
      isEmpty,
    );
    expect(
      await InventoryRepository(catalog.runner).getOnHandBase(productId),
      expectedOnHand,
    );
    final item = (await SalesRepository(catalog.runner).listSaleItems(saleId))
        .single;
    expect(item.quantityReturnedBase, expectedReturnedBase);
    final ledgerRows = await CustomerLedgerRepository(catalog.runner)
        .listForCustomer(customerId);
    expect(
      ledgerRows.where(
        (e) => e.entryType == CustomerLedgerEntryType.saleReturn.storage,
      ),
      isEmpty,
    );
  }

  group('return rollback', () {
    test('ledger failure rolls back return and stock', () async {
      final seeded = await seed();
      final saleId = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        qty: 2,
        checkoutKey: 'ret-roll-ledger',
      );
      final onHandAfterSale = await InventoryRepository(catalog.runner)
          .getOnHandBase(seeded.productId);
      final itemId = (await SalesRepository(
        catalog.runner,
      ).listSaleItems(saleId)).single.id;
      final ledger = FailingCustomerLedgerRepository(
        catalog.runner,
        failOnType: CustomerLedgerEntryType.saleReturn,
      );
      final sales = SalesRepository(catalog.runner, ledger: ledger);
      await expectLater(
        () => sales.returnSale(
          saleId: saleId,
          idempotencyKey: 'ret-fail-ledger',
          reason: 'defect',
          lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
        ),
        throwsA(isA<SalesConflictException>()),
      );
      await assertReturnStateClean(
        saleId: saleId,
        productId: seeded.productId,
        customerId: seeded.customerId,
        expectedOnHand: onHandAfterSale,
        expectedReturnedBase: 0,
      );
    });

    test('mid-return inventory failure rolls back partial work', () async {
      final seeded = await seed();
      await stockIn(seeded.productId, 20);
      final salesBase = SalesRepository(catalog.runner);
      final draft = await salesBase.createDraft(customerId: seeded.customerId);
      await salesBase.addDraftItem(
        saleId: draft.id,
        productId: seeded.productId,
        quantityBase: 2,
      );
      final product2 = await catalog.products.createProduct(
        name: 'Second SKU',
        costPriceMinor: 100,
        sellingPriceMinor: 500,
      );
      await stockIn(product2.id, 10);
      await salesBase.addDraftItem(
        saleId: draft.id,
        productId: product2.id,
        quantityBase: 2,
      );
      await salesBase.checkout(
        saleId: draft.id,
        checkoutIdempotencyKey: 'two-line-sale',
        payments: const [],
      );
      final items = await salesBase.listSaleItems(draft.id);
      final onHand1 = await InventoryRepository(catalog.runner)
          .getOnHandBase(seeded.productId);
      final onHand2 = await InventoryRepository(catalog.runner)
          .getOnHandBase(product2.id);
      final inventory = FailingInventoryRepository(
        catalog.runner,
        failOnMovementType: StockMovementType.saleReturn,
        failAfterSuccessfulMovements: 1,
      );
      final sales = SalesRepository(catalog.runner, inventory: inventory);
      await expectLater(
        () => sales.returnSale(
          saleId: draft.id,
          idempotencyKey: 'ret-fail-mid',
          reason: 'multi',
          lines: [
            SaleReturnLineInput(saleItemId: items[0].id, quantityBase: 1),
            SaleReturnLineInput(saleItemId: items[1].id, quantityBase: 1),
          ],
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        await catalog.harness.database
            .select(catalog.harness.database.saleReturns)
            .get(),
        isEmpty,
      );
      expect(
        await catalog.harness.database
            .select(catalog.harness.database.saleReturnItems)
            .get(),
        isEmpty,
      );
      expect(
        await InventoryRepository(catalog.runner)
            .getOnHandBase(seeded.productId),
        onHand1,
      );
      expect(
        await InventoryRepository(catalog.runner).getOnHandBase(product2.id),
        onHand2,
      );
      final itemsAfter = await salesBase.listSaleItems(draft.id);
      for (final item in itemsAfter) {
        expect(item.quantityReturnedBase, 0);
      }
    });

    test('retry after injected failure persists exactly once', () async {
      final seeded = await seed();
      final saleId = await completedSale(
        productId: seeded.productId,
        customerId: seeded.customerId,
        qty: 2,
        checkoutKey: 'ret-retry',
      );
      final itemId = (await SalesRepository(
        catalog.runner,
      ).listSaleItems(saleId)).single.id;
      const idempotency = 'ret-retry-key';
      final onHandBefore = await InventoryRepository(catalog.runner)
          .getOnHandBase(seeded.productId);
      final failLedger = FailingCustomerLedgerRepository(
        catalog.runner,
        failOnceOnType: CustomerLedgerEntryType.saleReturn,
      );
      final failingSales = SalesRepository(catalog.runner, ledger: failLedger);
      await expectLater(
        () => failingSales.returnSale(
          saleId: saleId,
          idempotencyKey: idempotency,
          reason: 'retry',
          lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
        ),
        throwsA(isA<SalesConflictException>()),
      );
      await assertReturnStateClean(
        saleId: saleId,
        productId: seeded.productId,
        customerId: seeded.customerId,
        expectedOnHand: onHandBefore,
        expectedReturnedBase: 0,
      );
      final successSales = SalesRepository(catalog.runner);
      await successSales.returnSale(
        saleId: saleId,
        idempotencyKey: idempotency,
        reason: 'retry',
        lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
      );
      expect(
        await catalog.harness.database
            .select(catalog.harness.database.saleReturns)
            .get(),
        hasLength(1),
      );
      expect(
        await catalog.harness.database
            .select(catalog.harness.database.saleReturnItems)
            .get(),
        hasLength(1),
      );
      final movements = await catalog.harness.database
          .select(catalog.harness.database.stockMovements)
          .get();
      expect(
        movements
            .where(
              (m) =>
                  m.movementType == StockMovementType.saleReturn.storageValue,
            )
            .length,
        1,
      );
      expect(
        await InventoryRepository(catalog.runner)
            .getOnHandBase(seeded.productId),
        onHandBefore + 1,
      );
    });
  });

  test('return is account credit not cash refund', () async {
    final seeded = await seed();
    final saleId = await completedSale(
      productId: seeded.productId,
      customerId: seeded.customerId,
      qty: 1,
      checkoutKey: 'credit',
      paymentMinor: 1000,
    );
    final ledger = CustomerLedgerRepository(catalog.runner);
    expect(await ledger.outstandingBalanceMinor(seeded.customerId), 0);
    final itemId = (await SalesRepository(catalog.runner).listSaleItems(saleId))
        .single
        .id;
    await SalesRepository(catalog.runner).returnSale(
      saleId: saleId,
      idempotencyKey: 'credit-ret',
      reason: 'credit only',
      lines: [SaleReturnLineInput(saleItemId: itemId, quantityBase: 1)],
    );
    expect(await ledger.outstandingBalanceMinor(seeded.customerId), -1000);
    final payments = await SalesRepository(catalog.runner)
        .listSalePayments(saleId);
    expect(payments, hasLength(1));
  });
}
