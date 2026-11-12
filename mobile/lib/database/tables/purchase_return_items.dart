import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/products.dart';
import 'package:pos_mobile/database/tables/purchase_items.dart';
import 'package:pos_mobile/database/tables/purchase_returns.dart';

@DataClassName('PurchaseReturnItemRow')
class PurchaseReturnItems extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseReturnId => text().references(PurchaseReturns, #id)();

  TextColumn get purchaseItemId => text().references(PurchaseItems, #id)();

  TextColumn get productId => text().references(Products, #id)();

  IntColumn get quantityBase => integer()();

  IntColumn get unitCostMinor => integer()();

  IntColumn get lineTotalMinor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
