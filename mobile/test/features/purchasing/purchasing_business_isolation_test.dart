import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/data/services/business_database_coordinator.dart';
import 'package:pos_mobile/data/services/database_service.dart';

void main() {
  test('suppliers isolated per business database', () async {
    final root =
        '${Directory.systemTemp.path}/pakpos_purchase_iso_${DateTime.now().microsecondsSinceEpoch}';
    final coordinator = BusinessDatabaseCoordinator(root);
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
    final supplierA = await SupplierRepository(
      DatabaseRunner(serviceA.database),
    ).createSupplier(name: 'Shared Name Supplier');
    await SupplierRepository(DatabaseRunner(serviceB.database))
        .createSupplier(name: 'Shared Name Supplier');
    final onlyA = PurchaseRepository(DatabaseRunner(serviceA.database));
    final draft = await onlyA.createDraft(supplierId: supplierA.id);
    expect(draft.supplierId, supplierA.id);
    final bootstrap = await DatabaseService.open(
      storageDirectoryOverride: root,
    );
    addTearDown(bootstrap.dispose);
    expect(
      await SupplierRepository(DatabaseRunner(bootstrap.database))
          .listSuppliers(),
      isEmpty,
    );
  });
}
