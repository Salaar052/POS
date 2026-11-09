import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('SyncConflictRow')
@TableIndex(name: 'sync_conflicts_status', columns: {#status, #createdAtMs})
@TableIndex(name: 'sync_conflicts_entity', columns: {#entityType, #entityId})
class SyncConflicts extends Table {
  TextColumn get conflictId => text()();

  TextColumn get businessId => text().references(LocalBusiness, #businessId)();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get localSnapshotJson => text()();

  TextColumn get remoteSnapshotJson => text().nullable()();

  TextColumn get status => text()();

  IntColumn get createdAtMs => integer()();

  IntColumn get resolvedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {conflictId};
}
