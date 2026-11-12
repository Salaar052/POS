import 'package:drift/drift.dart';

@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get normalizedName => text()();

  TextColumn get contactPerson => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get email => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get taxRegistrationNumber => text().nullable()();

  TextColumn get notes => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  IntColumn get archivedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
