import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/database/app_database.dart'
    hide LocalBusinessCompanion;
import 'package:pos_mobile/database/migrations/legacy_v1_app_database.dart';

void main() {
  test('migrates schema v1 file through v3 and adds catalog tables', () async {
    final root =
        '${Directory.systemTemp.path}/pakpos_v3_${DateTime.now().microsecondsSinceEpoch}';
    final pakposDir = Directory('$root/pakpos');
    await pakposDir.create(recursive: true);
    final path = '${pakposDir.path}/local.sqlite';

    final legacy = LegacyV1AppDatabase(NativeDatabase(File(path)));
    await legacy.customStatement('PRAGMA foreign_keys = ON');
    await legacy
        .into(legacy.localBusiness)
        .insert(
          LocalBusinessCompanion.insert(
            singletonId: const Value(1),
            businessId: '550e8400-e29b-41d4-a716-446655440000',
            name: 'Legacy row',
            createdAtMs: 1,
            updatedAtMs: 1,
          ),
        );
    await legacy.close();

    final migrated = AppDatabase(NativeDatabase(File(path)));
    final versionAfter = await migrated
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(versionAfter.data['user_version'], 8);

    final tables = await migrated
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' "
          "AND name IN ('products', 'product_categories') ORDER BY name",
        )
        .get();
    expect(tables.map((r) => r.data['name'] as String).toList(), [
      'product_categories',
      'products',
    ]);

    final business = await migrated.select(migrated.localBusiness).getSingle();
    expect(business.name, 'Legacy row');
    await migrated.close();
  });
}
