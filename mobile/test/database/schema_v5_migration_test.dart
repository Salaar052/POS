import 'package:flutter_test/flutter_test.dart';

import '../helpers/catalog_test_harness.dart';

void main() {
  test('fresh provision includes purchasing tables at latest schema', () async {
    final catalog = await CatalogTestHarness.create();
    addTearDown(catalog.dispose);
    final version = await catalog.harness.database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data['user_version'], 8);
    final tables = await catalog.harness.database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name IN ('suppliers','purchases','purchase_items','supplier_ledger_entries')",
        )
        .get();
    expect(tables, hasLength(4));
    final movementsBefore = await catalog.harness.database
        .select(catalog.harness.database.stockMovements)
        .get();
    expect(movementsBefore, isEmpty);
  });
}
