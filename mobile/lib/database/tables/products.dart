import 'package:drift/drift.dart';
import 'package:pos_mobile/database/tables/product_categories.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  TextColumn get sku => text().nullable()();

  TextColumn get skuNormalized => text().nullable()();

  TextColumn get barcode => text().nullable()();

  TextColumn get barcodeNormalized => text().nullable()();

  TextColumn get categoryId =>
      text().nullable().references(ProductCategories, #id)();

  IntColumn get costPriceMinor => integer()();

  IntColumn get sellingPriceMinor => integer()();

  TextColumn get unit => text().withDefault(const Constant('each'))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  IntColumn get createdAtMs => integer()();

  IntColumn get updatedAtMs => integer()();

  IntColumn get archivedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
