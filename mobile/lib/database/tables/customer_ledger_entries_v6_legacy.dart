import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/customers.dart';

/// Pre–v7 customer ledger layout (schema v6 as shipped on origin/dev).
@DataClassName('CustomerLedgerEntryLegacyRow')
class CustomerLedgerEntriesV6Legacy extends Table {
  @override
  String get tableName => 'customer_ledger_entries';

  TextColumn get id => text()();

  TextColumn get customerId => text().references(Customers, #id)();

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
