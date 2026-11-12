import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/products.dart';
import 'package:pos_mobile/database/tables/sale_items.dart';
import 'package:pos_mobile/database/tables/sale_returns.dart';

@DataClassName('SaleReturnItemRow')
class SaleReturnItems extends Table {
  TextColumn get id => text()();

  TextColumn get saleReturnId => text().references(SaleReturns, #id)();

  TextColumn get saleItemId => text().references(SaleItems, #id)();

  TextColumn get productId => text().references(Products, #id)();

  IntColumn get quantityBase => integer()();

  IntColumn get unitPriceMinor => integer()();

  IntColumn get lineTotalMinor => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
