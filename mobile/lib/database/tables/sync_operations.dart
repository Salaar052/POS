import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('SyncOperationRow')
@TableIndex(name: 'sync_ops_status_created', columns: {#status, #createdAtMs})
@TableIndex(
  name: 'sync_ops_entity',
  columns: {#businessId, #entityType, #entityId},
)
@TableIndex(name: 'sync_ops_depends_on', columns: {#dependsOnOperationId})
class SyncOperations extends Table {
  TextColumn get operationId => text()();

  TextColumn get businessId => text().references(LocalBusiness, #businessId)();

  TextColumn get deviceId => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get operationType => text()();

  TextColumn get payloadJson => text()();

  TextColumn get dependsOnOperationId =>
      text().nullable().references(SyncOperations, #operationId)();

  TextColumn get status => text()();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  TextColumn get lastErrorCode => text().nullable()();

  TextColumn get lastErrorMessage => text().nullable()();

  IntColumn get lastAttemptAtMs => integer().nullable()();

  IntColumn get acknowledgedAtMs => integer().nullable()();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}
