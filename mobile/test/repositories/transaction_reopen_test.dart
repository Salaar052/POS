import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/sync_queue_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/connection/open_database.dart';

void main() {
  test('transaction rollback on enqueue failure', () async {
    final db = openMemoryDatabase();
    final runner = DatabaseRunner(db);
    await LocalBusinessRepository(runner)
        .provisionBusiness(businessId: 'biz-a', name: 'Shop');
    final sync = SyncQueueRepository(runner);
    await expectLater(
      () => runner.runInTransaction(() async {
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await db
            .into(db.appSettings)
            .insert(
              AppSettingsCompanion.insert(
                settingKey: 'tax',
                businessId: 'biz-a',
                valueJson: '{"rate":17}',
                updatedAtMs: now,
              ),
            );
        await sync.enqueueInTransaction(
          businessId: 'biz-a',
          deviceId: 'dev',
          entityType: 'app_setting',
          entityId: 'tax',
          operationType: 'update',
          payload: {'rate': 17},
        );
        throw Exception('forced');
      }),
      throwsA(isA<Exception>()),
    );
    final row = await (db.select(
      db.appSettings,
    )..where((t) => t.settingKey.equals('tax'))).getSingleOrNull();
    expect(row, isNull);
    final ops = await db.select(db.syncOperations).get();
    expect(ops, isEmpty);
    await db.close();
  });

  test('file database persists after reopen', () async {
    final dir = await Directory.systemTemp.createTemp('pakpos_test');
    final path = p.join(dir.path, 'business_biz-a.sqlite');
    final openFirst = openFileDatabase(path);
    await LocalBusinessRepository(DatabaseRunner(openFirst))
        .provisionBusiness(businessId: 'biz-a', name: 'Persistent Shop');
    await openFirst.close();

    final openSecond = openFileDatabase(path);
    final business = await LocalBusinessRepository(DatabaseRunner(openSecond))
        .getBusiness();
    expect(business?.name, 'Persistent Shop');
    await openSecond.close();
    await dir.delete(recursive: true);
  });
}
