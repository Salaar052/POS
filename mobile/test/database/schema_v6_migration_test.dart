import 'package:flutter_test/flutter_test.dart';

import '../helpers/catalog_test_harness.dart';

void main() {
  test('schema v6 includes sales tables and preserves catalog', () async {
    final catalog = await CatalogTestHarness.create();
    addTearDown(catalog.dispose);
    final version = await catalog.harness.database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.data['user_version'], 6);
    final tables = await catalog.harness.database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name IN ('customers','sales','sale_items','customer_ledger_entries')",
        )
        .get();
    expect(tables, hasLength(4));
  });
}
