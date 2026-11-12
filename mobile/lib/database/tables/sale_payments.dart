import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/sales.dart';

@DataClassName('SalePaymentRow')
class SalePayments extends Table {
  TextColumn get id => text()();

  TextColumn get saleId => text().references(Sales, #id)();

  TextColumn get paymentMethod => text()();

  IntColumn get amountMinor => integer()();

  TextColumn get referenceNumber => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get idempotencyKey => text()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
