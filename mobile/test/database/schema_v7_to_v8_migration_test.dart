import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/migrations/legacy_v6_app_database.dart'
    as v6db;
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

void main() {
  test('v8 migration backfills legacy completed sale invoice numbers', () async {
    final root =
        '${Directory.systemTemp.path}/pakpos_v7inv_${DateTime.now().microsecondsSinceEpoch}';
    await Directory(root).create(recursive: true);
    final path = '$root/business.sqlite';

    const saleId = '550e8400-e29b-41d4-a716-446655440030';

    final v6 = v6db.LegacyV6AppDatabase(NativeDatabase(File(path)));
    await v6.customStatement('PRAGMA foreign_keys = ON');
    await v6.into(v6.sales).insert(
          v6db.SalesCompanion.insert(
            id: saleId,
            saleNumber: 'SO-000099',
            status: SaleStatus.completed.storage,
            subtotalMinor: 1000,
            discountMinor: 0,
            totalMinor: 1000,
            amountDueMinor: 0,
            createdAtMs: 1,
            updatedAtMs: 1,
            completedAtMs: const Value(1),
          ),
        );
    await v6.close();

    final migrated = AppDatabase(NativeDatabase(File(path)));
    final versionAfter = await migrated
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(versionAfter.data['user_version'], 8);

    final sale = await (migrated.select(
      migrated.sales,
    )..where((t) => t.id.equals(saleId))).getSingle();
    expect(sale.invoiceNumber, 'INV-LEG-SO-000099');

    final settings = await migrated
        .select(migrated.receiptSettings)
        .getSingle();
    expect(settings.singletonId, 1);
    expect(settings.invoicePrefix, 'INV');

    await migrated.close();
  });
}
