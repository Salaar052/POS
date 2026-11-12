import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/purchases.dart';
import 'package:pos_mobile/database/tables/suppliers.dart';

@DataClassName('PurchaseReturnRow')
class PurchaseReturns extends Table {
  TextColumn get id => text()();

  TextColumn get returnNumber => text()();

  TextColumn get purchaseId => text().references(Purchases, #id)();

  TextColumn get supplierId => text().references(Suppliers, #id)();

  TextColumn get reason => text()();

  IntColumn get totalMinor => integer()();

  TextColumn get status => text()();

  TextColumn get idempotencyKey => text()();

  IntColumn get createdAtMs => integer()();

  IntColumn get completedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
