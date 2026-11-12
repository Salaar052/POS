import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  late CatalogTestHarness catalog;

  setUp(() async {
    catalog = await CatalogTestHarness.create();
  });

  tearDown(() async {
    await catalog.dispose();
  });

  test('creates and reads product with minor-unit prices', () async {
    final created = await catalog.products.createProduct(
      name: ' Basmati Rice ',
      sku: ' rice-01 ',
      costPriceMinor: 15000,
      sellingPriceMinor: 19999,
    );
    expect(created.name, 'Basmati Rice');
    expect(created.skuNormalized, 'RICE-01');
    final loaded = await catalog.products.getById(created.id);
    expect(loaded?.sellingPriceMinor, 19999);
  });

  test('rejects duplicate SKU within business', () async {
    await catalog.products.createProduct(
      name: 'Item A',
      sku: 'SKU-1',
      costPriceMinor: 0,
      sellingPriceMinor: 100,
    );
    await expectLater(
      () => catalog.products.createProduct(
        name: 'Item B',
        sku: 'sku-1',
        costPriceMinor: 0,
        sellingPriceMinor: 100,
      ),
      throwsA(
        isA<CatalogConflictException>().having(
          (e) => e.code,
          'code',
          CatalogConflictCode.duplicateSku,
        ),
      ),
    );
  });

  test('rejects duplicate barcode within business', () async {
    await catalog.products.createProduct(
      name: 'Item A',
      barcode: '8960123456789',
      costPriceMinor: 0,
      sellingPriceMinor: 100,
    );
    await expectLater(
      () => catalog.products.createProduct(
        name: 'Item B',
        barcode: '8960123456789',
        costPriceMinor: 0,
        sellingPriceMinor: 100,
      ),
      throwsA(
        isA<CatalogConflictException>().having(
          (e) => e.code,
          'code',
          CatalogConflictCode.duplicateBarcode,
        ),
      ),
    );
  });

  test('search by name sku and barcode', () async {
    await catalog.products.createProduct(
      name: 'Green Tea',
      sku: 'TEA-GR',
      barcode: '12345',
      costPriceMinor: 5000,
      sellingPriceMinor: 7500,
    );
    expect(await catalog.products.searchByName('green'), hasLength(1));
    expect(await catalog.products.findBySku('tea-gr'), isNotNull);
    expect(await catalog.products.findByBarcode('12345'), isNotNull);
  });

  test('filters by category and archives product', () async {
    final category = await catalog.categories.createCategory(name: 'Beverages');
    final product = await catalog.products.createProduct(
      name: 'Cola',
      categoryId: category.id,
      costPriceMinor: 10000,
      sellingPriceMinor: 12000,
    );
    final filtered = await catalog.products.listProducts(
      ProductListQuery(categoryId: category.id),
    );
    expect(filtered.map((p) => p.id), contains(product.id));
    await catalog.products.archiveProduct(product.id);
    final active = await catalog.products.listProducts(
      const ProductListQuery(),
    );
    expect(active, isEmpty);
  });

  test('rejects negative prices', () async {
    await expectLater(
      () => catalog.products.createProduct(
        name: 'Invalid',
        costPriceMinor: -1,
        sellingPriceMinor: 0,
      ),
      throwsA(isA<CatalogValidationException>()),
    );
  });
}
