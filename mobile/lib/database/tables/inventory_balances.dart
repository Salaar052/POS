import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/products.dart';

@DataClassName('InventoryBalanceRow')
class InventoryBalances extends Table {
  TextColumn get productId => text().references(Products, #id)();

  IntColumn get quantityOnHandBase =>
      integer().withDefault(const Constant(0))();

  /// Null means no low-stock threshold configured for this product.
  IntColumn get minimumStockBase => integer().nullable()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}
