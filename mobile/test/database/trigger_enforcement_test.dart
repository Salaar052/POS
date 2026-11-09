import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/local_device_repository.dart';
import 'package:pos_mobile/data/repositories/sync_queue_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/activation_status.dart';
import 'package:pos_mobile/database/enums/sync_operation_type.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHarness harness;
  late DatabaseRunner runner;

  setUp(() async {
    harness = TestDatabaseHarness.memory();
    runner = harness.runner;
    await LocalBusinessRepository(runner).provisionBusiness(
      businessId: 'biz-a',
      name: 'Shop',
    );
    await LocalDeviceRepository(runner).registerDevice(
      deviceId: 'dev-1',
      businessId: 'biz-a',
      platform: 'windows',
    );
  });

  tearDown(() async {
    await harness.close();
  });

  test('DELETE on sync_operations is rejected by trigger', () async {
    final sync = SyncQueueRepository(runner);
    final opId = await sync.enqueueInTransaction(
      businessId: 'biz-a',
      deviceId: 'dev-1',
      entityType: 't',
      entityId: '1',
      operationType: SyncOperationType.create,
      payload: {},
    );
    expect(
      () => (harness.database.delete(harness.database.syncOperations)
            ..where((t) => t.operationId.equals(opId)))
          .go(),
      throwsA(anything),
    );
  });

  test('second local_device row insert is rejected by trigger', () async {
    expect(
      () => harness.database.into(harness.database.localDevice).insert(
            LocalDeviceCompanion.insert(
              singletonId: const Value(2),
              deviceId: 'dev-2',
              businessId: 'biz-a',
              platform: 'windows',
              activationStatus: ActivationStatus.unregistered,
              createdAtMs: 0,
              updatedAtMs: 0,
            ),
          ),
      throwsA(anything),
    );
  });
}
