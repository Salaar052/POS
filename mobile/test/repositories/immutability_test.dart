import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/data/repositories/audit_repository.dart';
import 'package:pos_mobile/data/repositories/local_business_repository.dart';
import 'package:pos_mobile/data/repositories/sync_queue_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/sync_operation_type.dart';
import 'package:pos_mobile/database/validators/json_validator.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHarness harness;

  setUp(() async {
    harness = TestDatabaseHarness.memory();
    await LocalBusinessRepository(harness.runner)
        .provisionBusiness(businessId: 'biz-a', name: 'Shop');
  });

  tearDown(() async {
    await harness.close();
  });

  test('sync payload is immutable', () async {
    final sync = SyncQueueRepository(harness.runner);
    final id = await sync.enqueueInTransaction(
      businessId: 'biz-a',
      deviceId: 'dev',
      entityType: 't',
      entityId: '1',
      operationType: SyncOperationType.update,
      payload: {'a': 1},
    );
    expect(
      () async =>
          (harness.database.update(
            harness.database.syncOperations,
          )..where((t) => t.operationId.equals(id))).write(
            const SyncOperationsCompanion(payloadJson: Value('{"a":2}')),
          ),
      throwsA(anything),
    );
  });

  test('audit events reject update and delete', () async {
    final audit = AuditRepository(harness.runner);
    await audit.recordEvent(deviceId: 'dev', eventType: 'test');
    final row = await harness.database
        .select(harness.database.auditEvents)
        .getSingle();
    expect(
      () => harness.database.update(harness.database.auditEvents).replace(row),
      throwsA(anything),
    );
    expect(
      () => (harness.database.delete(
        harness.database.auditEvents,
      )..where((t) => t.eventId.equals(row.eventId))).go(),
      throwsA(anything),
    );
  });

  test('json validator rejects invalid json', () {
    final validator = JsonValidator();
    expect(
      () => validator.validateEncoded('{bad'),
      throwsA(isA<JsonValidationException>()),
    );
  });
}
