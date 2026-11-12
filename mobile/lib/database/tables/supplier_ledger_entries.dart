import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/suppliers.dart';

@DataClassName('SupplierLedgerEntryRow')
class SupplierLedgerEntries extends Table {
  TextColumn get id => text()();

  TextColumn get supplierId => text().references(Suppliers, #id)();

  TextColumn get entryType => text()();

  IntColumn get debitMinor => integer().withDefault(const Constant(0))();

  IntColumn get creditMinor => integer().withDefault(const Constant(0))();

  TextColumn get referenceType => text()();

  TextColumn get referenceId => text()();

  TextColumn get notes => text().nullable()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
