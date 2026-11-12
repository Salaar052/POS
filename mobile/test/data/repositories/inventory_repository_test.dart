import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/features/inventory/domain/inventory_exceptions.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  late CatalogTestHarness catalog;

  setUp(() async {
    catalog = await CatalogTestHarness.create();
  });

  tearDown(() async {
    await catalog.dispose();
  });

  Future<String> createProduct({String unit = 'each'}) async {
    final product = await catalog.products.createProduct(
      name: 'Stock item',
      costPriceMinor: 100,
      sellingPriceMinor: 200,
      unit: unit,
    );
    return product.id;
  }

  test('opening stock and movement history', () async {
    final inventory = InventoryRepository(catalog.runner);
    final productId = await createProduct();
    await inventory.recordOpeningStock(
      productId: productId,
      quantityBase: 10,
      idempotencyKey: 'open-1',
    );
    expect(await inventory.getOnHandBase(productId), 10);
    final movements = await inventory.listMovements(productId);
    expect(movements, hasLength(1));
    expect(movements.single.movementType, 'OPENING_STOCK');
  });

  test('prevents negative stock on outbound movement', () async {
    final inventory = InventoryRepository(catalog.runner);
    final productId = await createProduct();
    await inventory.recordOpeningStock(
      productId: productId,
      quantityBase: 5,
      idempotencyKey: 'open-2',
    );
    await expectLater(
      () => inventory.recordAdjustmentOut(
        productId: productId,
        quantityBase: 6,
        idempotencyKey: 'out-1',
        reason: 'test',
      ),
      throwsA(
        isA<InventoryConflictException>().having(
          (e) => e.code,
          'code',
          InventoryConflictCode.insufficientStock,
        ),
      ),
    );
  });

  test(
    'duplicate idempotency returns same movement without double counting',
    () async {
      final inventory = InventoryRepository(catalog.runner);
      final productId = await createProduct();
      final first = await inventory.recordOpeningStock(
        productId: productId,
        quantityBase: 4,
        idempotencyKey: 'dup-key',
      );
      final second = await inventory.recordOpeningStock(
        productId: productId,
        quantityBase: 4,
        idempotencyKey: 'dup-key',
      );
      expect(second.id, first.id);
      expect(await inventory.getOnHandBase(productId), 4);
    },
  );

  test('reversal creates compensating movement', () async {
    final inventory = InventoryRepository(catalog.runner);
    final productId = await createProduct();
    final movement = await inventory.recordOpeningStock(
      productId: productId,
      quantityBase: 8,
      idempotencyKey: 'open-rev',
    );
    await inventory.reverseMovement(
      movementId: movement.id,
      idempotencyKey: 'rev-1',
    );
    expect(await inventory.getOnHandBase(productId), 0);
  });

  test('low stock status uses explicit minimum threshold', () async {
    final inventory = InventoryRepository(catalog.runner);
    final productId = await createProduct();
    await inventory.recordOpeningStock(
      productId: productId,
      quantityBase: 5,
      idempotencyKey: 'open-min',
    );
    await inventory.setMinimumStock(productId: productId, minimumStockBase: 10);
    final overview = await inventory.listOverview();
    final row = overview.firstWhere((r) => r.product.id == productId);
    expect(row.status, StockStatus.lowStock);
  });

  test('archived product movements remain readable', () async {
    final inventory = InventoryRepository(catalog.runner);
    final productId = await createProduct();
    await inventory.recordOpeningStock(
      productId: productId,
      quantityBase: 3,
      idempotencyKey: 'arch',
    );
    await catalog.products.archiveProduct(productId);
    expect(await inventory.listMovements(productId), isNotEmpty);
  });
}
