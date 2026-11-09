import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/local_business.dart';

@DataClassName('UsersCacheRow')
class UsersCache extends Table {
  TextColumn get userId => text()();

  TextColumn get businessId =>
      text().references(LocalBusiness, #businessId)();

  TextColumn get displayName => text()();

  TextColumn get role => text()();

  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  IntColumn get lastSyncedAtMs => integer().nullable()();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}
