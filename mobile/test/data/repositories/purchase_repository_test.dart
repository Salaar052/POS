import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_exceptions.dart';
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

  Future<({String productId, String supplierId})>
  seedProductAndSupplier() async {
    final supplier = await SupplierRepository(catalog.runner)
        .createSupplier(name: 'Purchase Test Supplier');
    final product = await catalog.products.createProduct(
      name: 'Rice Bag',
      costPriceMinor: 10000,
      sellingPriceMinor: 12000,
      unit: 'each',
    );
    return (productId: product.id, supplierId: supplier.id);
  }

  test('draft does not affect stock', () async {
    final purchases = PurchaseRepository(catalog.runner);
    final inventory = InventoryRepository(catalog.runner);
    final seeded = await seedProductAndSupplier();
    final draft = await purchases.createDraft(supplierId: seeded.supplierId);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: seeded.productId,
      quantityBase: 10,
      unitCostMinor: 10000,
    );
    expect(await inventory.getOnHandBase(seeded.productId), 0);
  });

  test('receive increases stock once and records payable', () async {
    final purchases = PurchaseRepository(catalog.runner);
    final inventory = InventoryRepository(catalog.runner);
    final ledger = SupplierLedgerRepository(catalog.runner);
    final seeded = await seedProductAndSupplier();
    final draft = await purchases.createDraft(supplierId: seeded.supplierId);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: seeded.productId,
      quantityBase: 5,
      unitCostMinor: 1000,
    );
    const receiveKey = 'recv-test-1';
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: receiveKey,
    );
    expect(await inventory.getOnHandBase(seeded.productId), 5);
    expect(await ledger.outstandingBalanceMinor(seeded.supplierId), 5000);
    final dup = await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: receiveKey,
    );
    expect(dup.status, PurchaseStatus.received.storage);
    expect(await inventory.getOnHandBase(seeded.productId), 5);
  });

  test('duplicate receive key on new attempt rejected', () async {
    final purchases = PurchaseRepository(catalog.runner);
    final seeded = await seedProductAndSupplier();
    final draft = await purchases.createDraft(supplierId: seeded.supplierId);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: seeded.productId,
      quantityBase: 1,
      unitCostMinor: 100,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: 'first',
    );
    await expectLater(
      () => purchases.receivePurchase(
        purchaseId: draft.id,
        receiveIdempotencyKey: const Uuid().v4(),
      ),
      throwsA(isA<PurchasingConflictException>()),
    );
  });

  test('payment reduces supplier balance', () async {
    final purchases = PurchaseRepository(catalog.runner);
    final ledger = SupplierLedgerRepository(catalog.runner);
    final seeded = await seedProductAndSupplier();
    final draft = await purchases.createDraft(supplierId: seeded.supplierId);
    await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: seeded.productId,
      quantityBase: 2,
      unitCostMinor: 5000,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: 'pay-recv',
    );
    await purchases.recordPayment(
      purchaseId: draft.id,
      amountMinor: 5000,
      method: PurchasePaymentMethod.cash,
      idempotencyKey: 'pay-1',
    );
    expect(await ledger.outstandingBalanceMinor(seeded.supplierId), 5000);
  });

  test('purchase return decreases stock and credits supplier', () async {
    final purchases = PurchaseRepository(catalog.runner);
    final inventory = InventoryRepository(catalog.runner);
    final ledger = SupplierLedgerRepository(catalog.runner);
    final seeded = await seedProductAndSupplier();
    final draft = await purchases.createDraft(supplierId: seeded.supplierId);
    final item = await purchases.addDraftItem(
      purchaseId: draft.id,
      productId: seeded.productId,
      quantityBase: 4,
      unitCostMinor: 1000,
    );
    await purchases.receivePurchase(
      purchaseId: draft.id,
      receiveIdempotencyKey: 'ret-recv',
    );
    await purchases.completePurchaseReturn(
      purchaseId: draft.id,
      reason: 'Damaged',
      idempotencyKey: 'ret-1',
      lines: [
        PurchaseReturnLineRequest(purchaseItemId: item.id, quantityBase: 1),
      ],
    );
    expect(await inventory.getOnHandBase(seeded.productId), 3);
    expect(await ledger.outstandingBalanceMinor(seeded.supplierId), 3000);
  });
}
