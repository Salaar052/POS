import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/customers.dart';

@DataClassName('SaleRow')
class Sales extends Table {
  TextColumn get id => text()();

  TextColumn get saleNumber => text()();

  TextColumn get customerId => text().nullable().references(Customers, #id)();

  TextColumn get customerNameSnapshot => text().nullable()();

  TextColumn get status => text()();

  IntColumn get subtotalMinor => integer()();

  IntColumn get discountMinor => integer()();

  IntColumn get totalMinor => integer()();

  IntColumn get amountPaidMinor => integer().withDefault(const Constant(0))();

  IntColumn get amountDueMinor => integer()();

  TextColumn get notes => text().nullable()();

  TextColumn get checkoutIdempotencyKey => text().nullable()();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  IntColumn get completedAtMs => integer().nullable()();

  IntColumn get cancelledAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
