import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get settingKey => text()();

  TextColumn get businessId => text().references(LocalBusiness, #businessId)();

  TextColumn get valueJson => text()();

  IntColumn get updatedAtMs => integer()();

  TextColumn get updatedByUserId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}
