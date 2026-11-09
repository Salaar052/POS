import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('LocalDeviceRow')
class LocalDevice extends Table {
  IntColumn get singletonId => integer()();

  TextColumn get deviceId => text().unique()();

  TextColumn get businessId => text().references(LocalBusiness, #businessId)();

  TextColumn get platform => text()();

  TextColumn get label => text().nullable()();

  TextColumn get activationStatus => text()();

  IntColumn get activatedAtMs => integer().nullable()();

  IntColumn get lastOnlineValidatedAtMs => integer().nullable()();

  IntColumn get offlineValidUntilMs => integer().nullable()();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};
}
