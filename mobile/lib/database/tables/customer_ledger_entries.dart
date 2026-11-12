import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/customers.dart';

@DataClassName('CustomerLedgerEntryRow')
class CustomerLedgerEntries extends Table {
  TextColumn get id => text()();

  TextColumn get customerId => text().references(Customers, #id)();

  TextColumn get entryType => text()();

  IntColumn get debitMinor => integer().withDefault(const Constant(0))();

  IntColumn get creditMinor => integer().withDefault(const Constant(0))();

  TextColumn get referenceType => text()();

  TextColumn get referenceId => text()();

  TextColumn get paymentMethod => text().nullable()();

  TextColumn get referenceNumber => text().nullable()();

  TextColumn get notes => text().nullable()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
