import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/migrations/legacy_v5_app_database.dart'
    as v5db;

void main() {
  test('upgrades real v5 database to v6 preserving purchasing data', () async {
    final root =
        '${Directory.systemTemp.path}/pakpos_v5_${DateTime.now().microsecondsSinceEpoch}';
    final dir = Directory(root);
    await dir.create(recursive: true);
    final path = '${dir.path}/business.sqlite';

    const productId = '550e8400-e29b-41d4-a716-446655440010';
    const supplierId = '550e8400-e29b-41d4-a716-446655440011';

    final v5 = v5db.LegacyV5AppDatabase(NativeDatabase(File(path)));
    await v5.customStatement('PRAGMA foreign_keys = ON');
    await v5
        .into(v5.localBusiness)
        .insert(
          v5db.LocalBusinessCompanion.insert(
            businessId: '550e8400-e29b-41d4-a716-446655440099',
            name: 'V5 Shop',
            createdAtMs: 1,
            updatedAtMs: 1,
          ),
        );
    await v5
        .into(v5.products)
        .insert(
          v5db.ProductsCompanion.insert(
            id: productId,
            name: 'Pre-migration Widget',
            costPriceMinor: 100,
            sellingPriceMinor: 200,
            createdAtMs: 1,
            updatedAtMs: 1,
          ),
        );
    await v5
        .into(v5.suppliers)
        .insert(
          v5db.SuppliersCompanion.insert(
            id: supplierId,
            name: 'Pre-migration Supplier',
            normalizedName: 'pre-migration supplier',
            createdAtMs: 1,
            updatedAtMs: 1,
          ),
        );
    final versionV5 = await v5.customSelect('PRAGMA user_version').getSingle();
    expect(versionV5.data['user_version'], 5);
    await v5.close();

    final migrated = AppDatabase(NativeDatabase(File(path)));
    final versionAfter = await migrated
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(versionAfter.data['user_version'], 8);

    final salesTables = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name IN ('customers','sales','sale_items','customer_ledger_entries')",
        )
        .get();
    expect(salesTables, hasLength(4));

    final productAfter = await (migrated.select(
      migrated.products,
    )..where((t) => t.id.equals(productId))).getSingleOrNull();
    expect(productAfter?.name, 'Pre-migration Widget');

    final supplierAfter = await (migrated.select(
      migrated.suppliers,
    )..where((t) => t.id.equals(supplierId))).getSingleOrNull();
    expect(supplierAfter?.name, 'Pre-migration Supplier');

    final ledgerInfo = await migrated
        .customSelect("PRAGMA table_info(customer_ledger_entries)")
        .get();
    final columnNames = ledgerInfo
        .map((r) => r.data['name'] as String)
        .toList();
    expect(columnNames, contains('payment_method'));
    expect(columnNames, contains('reference_number'));

    await migrated.close();
  });
}
