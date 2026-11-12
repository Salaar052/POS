import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/supplier_repository.dart';
import 'package:pos_mobile/data/repositories/supplier_ledger_repository.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';

import '../../helpers/catalog_test_harness.dart';

void main() {
  late CatalogTestHarness catalog;

  setUp(() async {
    catalog = await CatalogTestHarness.create();
  });

  tearDown(() async {
    await catalog.dispose();
  });

  test('creates and searches supplier', () async {
    final repo = SupplierRepository(catalog.runner);
    final s = await repo.createSupplier(
      name: 'Karachi Wholesalers',
      phone: '03001234567',
    );
    final found = await repo.listSuppliers(query: 'karachi');
    expect(found.map((e) => e.id), contains(s.id));
  });

  test('ledger outstanding balance', () async {
    final suppliers = SupplierRepository(catalog.runner);
    final ledger = SupplierLedgerRepository(catalog.runner);
    final s = await suppliers.createSupplier(name: 'Ledger Test');
    await ledger.appendEntry(
      supplierId: s.id,
      type: SupplierLedgerEntryType.purchasePayable,
      debitMinor: 5000,
      creditMinor: 0,
      referenceType: 'TEST',
      referenceId: '1',
    );
    await ledger.appendEntry(
      supplierId: s.id,
      type: SupplierLedgerEntryType.payment,
      debitMinor: 0,
      creditMinor: 2000,
      referenceType: 'TEST',
      referenceId: '2',
    );
    expect(await ledger.outstandingBalanceMinor(s.id), 3000);
  });
}
