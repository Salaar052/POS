import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/sync_queue_repository.dart';
import 'package:pos_mobile/database/enums/sync_operation_status.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/sync_operation_type.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHarness harness;
  late SyncQueueRepository sync;

  const businessId = 'biz-a';
  const deviceId = 'dev-1';

  setUp(() async {
    harness = TestDatabaseHarness.memory();
    sync = SyncQueueRepository(harness.runner);
    await LocalBusinessRepository(harness.runner).provisionBusiness(
      businessId: businessId,
      name: 'Shop',
    );
  });

  tearDown(() async {
    await harness.close();
  });

  Future<String> enqueueParent() {
    return sync.enqueueInTransaction(
      businessId: businessId,
      deviceId: deviceId,
      entityType: 'app_setting',
      entityId: 'k1',
      operationType: SyncOperationType.update,
      payload: {'v': 1},
    );
  }

  test('dependent blocked until parent acknowledged', () async {
    final parentId = await enqueueParent();
    await sync.markInFlight(parentId);
    final childId = await sync.enqueueInTransaction(
      businessId: businessId,
      deviceId: deviceId,
      entityType: 'app_setting',
      entityId: 'k2',
      operationType: SyncOperationType.update,
      payload: {'v': 2},
      dependsOnOperationId: parentId,
    );
    final child = await sync.getOperation(childId);
    expect(child!.status, SyncOperationStatus.blocked);
    await sync.acknowledge(parentId);
    final promoted = await sync.getOperation(childId);
    expect(promoted!.status, SyncOperationStatus.pending);
  });

  test('failed parent keeps dependent blocked and preserved', () async {
    final parentId = await enqueueParent();
    await sync.markInFlight(parentId);
    final childId = await sync.enqueueInTransaction(
      businessId: businessId,
      deviceId: deviceId,
      entityType: 'app_setting',
      entityId: 'k3',
      operationType: SyncOperationType.update,
      payload: {'v': 3},
      dependsOnOperationId: parentId,
    );
    await sync.markFailedRetryable(
      operationId: parentId,
      errorCode: 'NET',
      errorMessage: 'timeout',
    );
    final parent = await sync.getOperation(parentId);
    final child = await sync.getOperation(childId);
    expect(parent!.status, SyncOperationStatus.failedRetryable);
    expect(parent.lastErrorMessage, 'timeout');
    expect(child!.status, SyncOperationStatus.blocked);
  });

  test('retry reuses operation id', () async {
    final id = await enqueueParent();
    await sync.markInFlight(id);
    await sync.markFailedRetryable(
      operationId: id,
      errorCode: 'NET',
      errorMessage: 'fail',
    );
    final failed = await sync.getOperation(id);
    expect(failed!.retryCount, 1);
    await sync.retryFromFailedRetryable(id);
    final retrying = await sync.getOperation(id);
    expect(retrying!.operationId, id);
    expect(retrying.status, SyncOperationStatus.inFlight);
  });

  test('acknowledged cannot return to pending', () async {
    final id = await enqueueParent();
    await sync.markInFlight(id);
    await sync.acknowledge(id);
    expect(
      () => sync.transitionStatus(
        operationId: id,
        toStatus: SyncOperationStatus.pending,
      ),
      throwsA(isA<SyncQueueException>()),
    );
  });

  test('rejects self dependency', () async {
    expect(
      () => sync.enqueueInTransaction(
        businessId: businessId,
        deviceId: deviceId,
        entityType: 'x',
        entityId: '1',
        operationType: SyncOperationType.update,
        payload: {},
        operationId: 'op-a',
        dependsOnOperationId: 'op-a',
      ),
      throwsA(isA<SyncQueueException>()),
    );
  });

  test('depends_on links are immutable after insert', () async {
    final a = await sync.enqueueInTransaction(
      businessId: businessId,
      deviceId: deviceId,
      entityType: 'a',
      entityId: '1',
      operationType: SyncOperationType.create,
      payload: {},
    );
    final b = await sync.enqueueInTransaction(
      businessId: businessId,
      deviceId: deviceId,
      entityType: 'b',
      entityId: '1',
      operationType: SyncOperationType.create,
      payload: {},
      dependsOnOperationId: a,
    );
    expect(
      () async => (harness.database.update(harness.database.syncOperations)
            ..where((t) => t.operationId.equals(b)))
          .write(
        SyncOperationsCompanion(dependsOnOperationId: Value(a)),
      ),
      returnsNormally,
    );
    final rowB = await sync.getOperation(b);
    expect(
      () async => (harness.database.update(harness.database.syncOperations)
            ..where((t) => t.operationId.equals(a)))
          .write(
        const SyncOperationsCompanion(
          dependsOnOperationId: Value('other'),
        ),
      ),
      throwsA(anything),
    );
    expect(rowB!.dependsOnOperationId, a);
  });
}
