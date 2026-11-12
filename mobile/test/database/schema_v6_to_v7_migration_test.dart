import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/migrations/legacy_v6_app_database.dart'
    as v6db;

void main() {
  test('upgrades legacy v6 ledger layout to v7 with payment metadata columns', () async {
    final root =
        '${Directory.systemTemp.path}/pakpos_v6_${DateTime.now().microsecondsSinceEpoch}';
    await Directory(root).create(recursive: true);
    final path = '$root/business.sqlite';

    const customerId = '550e8400-e29b-41d4-a716-446655440020';
    const ledgerId = '550e8400-e29b-41d4-a716-446655440021';

    final v6 = v6db.LegacyV6AppDatabase(NativeDatabase(File(path)));
    await v6.customStatement('PRAGMA foreign_keys = ON');
    await v6
        .into(v6.customers)
        .insert(
          v6db.CustomersCompanion.insert(
            id: customerId,
            name: 'Legacy Customer',
            normalizedName: 'legacy customer',
            createdAtMs: 1,
            updatedAtMs: 1,
          ),
        );
    await v6
        .into(v6.customerLedgerEntriesV6Legacy)
        .insert(
          v6db.CustomerLedgerEntriesV6LegacyCompanion.insert(
            id: ledgerId,
            customerId: customerId,
            entryType: 'CUSTOMER_PAYMENT',
            creditMinor: const Value(1000),
            referenceType: 'CUSTOMER_PAYMENT',
            referenceId: 'legacy-row',
            createdAtMs: 1,
          ),
        );
    final versionV6 = await v6.customSelect('PRAGMA user_version').getSingle();
    expect(versionV6.data['user_version'], 6);
    final beforeColumns = await v6
        .customSelect('PRAGMA table_info(customer_ledger_entries)')
        .get();
    final beforeNames = beforeColumns
        .map((r) => r.data['name'] as String)
        .toList();
    expect(beforeNames, isNot(contains('payment_method')));
    await v6.close();

    final migrated = AppDatabase(NativeDatabase(File(path)));
    final versionAfter = await migrated
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(versionAfter.data['user_version'], 8);

    final afterColumns = await migrated
        .customSelect('PRAGMA table_info(customer_ledger_entries)')
        .get();
    final afterNames = afterColumns
        .map((r) => r.data['name'] as String)
        .toList();
    expect(afterNames, containsAll(['payment_method', 'reference_number']));

    final row = await (migrated.select(
      migrated.customerLedgerEntries,
    )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
    expect(row?.creditMinor, 1000);
    expect(row?.referenceId, 'legacy-row');

    await migrated.close();
  });
}
