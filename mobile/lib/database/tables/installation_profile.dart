import 'package:drift/drift.dart';

@DataClassName('InstallationProfileRow')
class InstallationProfile extends Table {
  IntColumn get singletonId => integer()();

  TextColumn get appInstallId => text()();

  TextColumn get activeBusinessId => text().nullable()();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};
}
