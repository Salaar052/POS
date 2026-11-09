import 'package:drift/drift.dart';

@DataClassName('KnownBusinessRow')
class KnownBusinesses extends Table {
  TextColumn get businessId => text()();

  TextColumn get displayName => text()();

  TextColumn get databaseFileName => text()();

  TextColumn get provisioningStatus => text()();

  IntColumn get createdAtMs => integer()();

  IntColumn get lastOpenedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {businessId};
}
