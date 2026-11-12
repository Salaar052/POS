import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/product_repository.dart';
import 'package:pos_mobile/data/services/business_database_coordinator.dart';
import 'package:pos_mobile/data/services/database_service.dart';

void main() {
  late String storageRoot;
  late BusinessDatabaseCoordinator coordinator;

  setUp(() {
    storageRoot =
        '${Directory.systemTemp.path}/pakpos_catalog_iso_${DateTime.now().microsecondsSinceEpoch}';
    coordinator = BusinessDatabaseCoordinator(storageRoot);
  });

  test('same SKU in separate business databases does not conflict', () async {
    const businessA = '550e8400-e29b-41d4-a716-4466554400a1';
    const businessB = '550e8400-e29b-41d4-a716-4466554400b2';

    final serviceA = await coordinator.provisionBusinessDatabase(
      businessId: businessA,
      displayName: 'Shop A',
    );
    final serviceB = await coordinator.provisionBusinessDatabase(
      businessId: businessB,
      displayName: 'Shop B',
    );
    addTearDown(() async {
      await serviceA.dispose();
      await serviceB.dispose();
    });

    final repoA = ProductRepository(DatabaseRunner(serviceA.database));
    final repoB = ProductRepository(DatabaseRunner(serviceB.database));

    await repoA.createProduct(
      name: 'Shared Code Item',
      sku: 'SHARED-1',
      costPriceMinor: 0,
      sellingPriceMinor: 100,
    );
    await repoB.createProduct(
      name: 'Shared Code Item',
      sku: 'SHARED-1',
      costPriceMinor: 0,
      sellingPriceMinor: 200,
    );

    final foundInA = await repoA.findBySku('SHARED-1');
    final foundInB = await repoB.findBySku('SHARED-1');
    expect(foundInA?.sellingPriceMinor, 100);
    expect(foundInB?.sellingPriceMinor, 200);

    final bootstrap = await DatabaseService.open(
      storageDirectoryOverride: storageRoot,
    );
    addTearDown(bootstrap.dispose);
    expect(
      await LocalBusinessRepository(DatabaseRunner(bootstrap.database))
          .getBusiness(),
      isNull,
    );
  });
}
