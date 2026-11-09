import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('AuditEventRow')
@TableIndex(name: 'audit_events_created', columns: {#createdAtMs})
@TableIndex(
  name: 'audit_events_type',
  columns: {#businessId, #eventType, #createdAtMs},
)
class AuditEvents extends Table {
  TextColumn get eventId => text()();

  TextColumn get businessId => text().references(LocalBusiness, #businessId)();

  TextColumn get deviceId => text()();

  TextColumn get actorUserId => text().nullable()();

  TextColumn get eventType => text()();

  TextColumn get entityType => text().nullable()();

  TextColumn get entityId => text().nullable()();

  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}
