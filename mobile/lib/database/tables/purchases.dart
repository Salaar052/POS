import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/suppliers.dart';

@DataClassName('PurchaseRow')
class Purchases extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseNumber => text()();

  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();

  TextColumn get supplierNameSnapshot => text()();

  TextColumn get supplierInvoiceNumber => text().nullable()();

  TextColumn get status => text()();

  IntColumn get subtotalMinor => integer()();

  IntColumn get discountMinor => integer()();

  IntColumn get taxMinor => integer()();

  IntColumn get additionalChargesMinor => integer()();

  IntColumn get totalMinor => integer()();

  IntColumn get amountPaidMinor => integer().withDefault(const Constant(0))();

  IntColumn get amountDueMinor => integer()();

  TextColumn get paymentStatus => text()();

  TextColumn get notes => text().nullable()();

  IntColumn get purchaseDateMs => integer()();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  IntColumn get receivedAtMs => integer().nullable()();

  IntColumn get cancelledAtMs => integer().nullable()();

  TextColumn get receiveIdempotencyKey => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
