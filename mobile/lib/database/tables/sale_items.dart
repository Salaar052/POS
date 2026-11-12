import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/products.dart';
import 'package:pos_mobile/database/tables/sales.dart';

@DataClassName('SaleItemRow')
class SaleItems extends Table {
  TextColumn get id => text()();

  TextColumn get saleId => text().references(Sales, #id)();

  TextColumn get productId => text().references(Products, #id)();

  TextColumn get productNameSnapshot => text()();

  TextColumn get skuSnapshot => text().nullable()();

  TextColumn get barcodeSnapshot => text().nullable()();

  TextColumn get unitSnapshot => text()();

  IntColumn get quantityBase => integer()();

  IntColumn get quantityReturnedBase =>
      integer().withDefault(const Constant(0))();

  IntColumn get unitPriceMinor => integer()();

  IntColumn get discountMinor => integer().withDefault(const Constant(0))();

  IntColumn get lineTotalMinor => integer()();

  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
