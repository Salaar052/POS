import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('SyncCursorRow')
class SyncCursors extends Table {
  TextColumn get streamName => text()();

  TextColumn get businessId => text().references(LocalBusiness, #businessId)();

  TextColumn get cursorValue => text()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {streamName};
}
