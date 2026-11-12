import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/product_category_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';

import 'test_database.dart';

class CatalogTestHarness {
  CatalogTestHarness._({required this.harness, required this.businessId});

  final TestDatabaseHarness harness;
  final String businessId;

  DatabaseRunner get runner => harness.runner;

  ProductRepository get products => ProductRepository(runner);

  ProductCategoryRepository get categories => ProductCategoryRepository(runner);

  static Future<CatalogTestHarness> create({
    String businessId = '550e8400-e29b-41d4-a716-446655440001',
    String businessName = 'Catalog Test Shop',
  }) async {
    final harness = TestDatabaseHarness.memory();
    await LocalBusinessRepository(harness.runner)
        .provisionBusiness(businessId: businessId, name: businessName);
    return CatalogTestHarness._(harness: harness, businessId: businessId);
  }

  Future<void> dispose() => harness.close();
}
