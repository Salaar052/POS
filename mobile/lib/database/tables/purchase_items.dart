import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/products.dart';
import 'package:pos_mobile/database/tables/purchases.dart';

@DataClassName('PurchaseItemRow')
class PurchaseItems extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseId => text().references(Purchases, #id)();

  TextColumn get productId => text().references(Products, #id)();

  TextColumn get productNameSnapshot => text()();

  TextColumn get skuSnapshot => text().nullable()();

  TextColumn get unitSnapshot => text()();

  IntColumn get quantityBase => integer()();

  IntColumn get quantityReceivedBase =>
      integer().withDefault(const Constant(0))();

  IntColumn get quantityReturnedBase =>
      integer().withDefault(const Constant(0))();

  IntColumn get unitCostMinor => integer()();

  IntColumn get discountMinor => integer().withDefault(const Constant(0))();

  IntColumn get taxMinor => integer().withDefault(const Constant(0))();

  IntColumn get lineTotalMinor => integer()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
