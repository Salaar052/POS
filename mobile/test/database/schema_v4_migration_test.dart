import 'package:flutter_test/flutter_test.dart';

import '../helpers/catalog_test_harness.dart';

void main() {
  test(
    'provisioned business database is schema v4 with inventory tables',
    () async {
      final catalog = await CatalogTestHarness.create();
      addTearDown(catalog.dispose);
      final version = await catalog.harness.database
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data['user_version'], 8);
      final tables = await catalog.harness.database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name IN ('inventory_balances', 'stock_movements')",
          )
          .get();
      expect(tables, hasLength(2));
    },
  );
}
