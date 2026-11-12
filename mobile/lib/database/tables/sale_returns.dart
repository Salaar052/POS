import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/customers.dart';
import 'package:pos_mobile/database/tables/sales.dart';

@DataClassName('SaleReturnRow')
class SaleReturns extends Table {
  TextColumn get id => text()();

  TextColumn get returnNumber => text()();

  TextColumn get saleId => text().references(Sales, #id)();

  TextColumn get customerId => text().nullable().references(Customers, #id)();

  TextColumn get reason => text()();

  IntColumn get totalMinor => integer()();

  TextColumn get status => text()();

  TextColumn get idempotencyKey => text()();

  IntColumn get createdAtMs => integer()();

  IntColumn get completedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
