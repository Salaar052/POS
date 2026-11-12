import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  late CatalogTestHarness catalog;

  setUp(() async {
    catalog = await CatalogTestHarness.create();
  });

  tearDown(() async {
    await catalog.dispose();
  });

  test('creates category with normalized duplicate protection', () async {
    final created = await catalog.categories.createCategory(
      name: '  Cold Drinks  ',
    );
    expect(created.name, 'Cold Drinks');
    await expectLater(
      () => catalog.categories.createCategory(name: 'cold drinks'),
      throwsA(
        isA<CatalogConflictException>().having(
          (e) => e.code,
          'code',
          CatalogConflictCode.duplicateCategoryName,
        ),
      ),
    );
  });

  test('archives category without deleting linked products', () async {
    final category = await catalog.categories.createCategory(name: 'Snacks');
    final product = await catalog.products.createProduct(
      name: 'Chips',
      categoryId: category.id,
      costPriceMinor: 5000,
      sellingPriceMinor: 7000,
    );
    final counts = await catalog.categories.getWithProductCounts(category.id);
    expect(counts.productCount, 1);
    await catalog.categories.archiveCategory(category.id);
    final stillLinked = await catalog.products.getById(product.id);
    expect(stillLinked?.categoryId, category.id);
    final archivedCategories = await catalog.categories.listCategories(
      includeArchived: true,
    );
    expect(archivedCategories.single.isActive, isFalse);
  });
}
