import 'package:drift/drift.dart';

@DataClassName('LocalBusinessRow')
class LocalBusiness extends Table {
  IntColumn get singletonId => integer()();

  TextColumn get businessId => text().unique()();

  TextColumn get name => text()();

  TextColumn get legalName => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get timezoneId =>
      text().withDefault(const Constant('Asia/Karachi'))();

  TextColumn get currencyCode => text().withDefault(const Constant('PKR'))();

  TextColumn get settingsJson =>
      text().withDefault(const Constant('{}'))();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};
}
